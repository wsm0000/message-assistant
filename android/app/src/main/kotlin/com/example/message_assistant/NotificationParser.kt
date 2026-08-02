package com.example.message_assistant

import java.security.MessageDigest

/**
 * Parsed structured fields from a posted notification's title/text.
 *
 * This is the data-quality命脉 of the message assistant: WeChat notifications
 * arrive as (title, text) where title encodes the group name (group chat) or
 * the sender (single chat). This pure function extracts groupId/groupName/
 * senderName/content so the Dart pipeline doesn't have to re-parse.
 *
 * Parsing lives ONLY here (not duplicated in Dart) per the architecture
 * coordination decision — the EventChannel carries structured fields.
 *
 * groupId is a stable pseudo-id: sha1("$appId|$name") truncated to 16 hex
 * chars (same-name groups collapse to one id; MVP tradeoff, real ids via
 * Accessibility in a later phase).
 */
data class ParsedNotification(
    val appId: String,
    val groupId: String,
    val groupName: String?,
    val senderName: String,
    val content: String,
    val isGroup: Boolean,
)

object NotificationParser {
    /** Target packages we monitor. MVP: WeChat only. */
    private val TARGET_PACKAGES = setOf("com.tencent.mm")

    /**
     * Parse a notification. Returns null if the package isn't a target or the
     * text is empty (nothing to match).
     *
     * Chat-type detection (resolves the inherent ambiguity of a bare title):
     *   - Group chat (case A): title matches "群名(N)" — trailing parenthesized
     *     unread count. groupName is the part before "(N)".
     *   - Group chat (case B): title is present (no count parens) AND the text
     *     contains a colon (sender:content). The bare title is treated as the
     *     group name; the colon split extracts sender/content. This makes
     *     "货运华东群" and "货运华东群(9)" collapse to one stable groupId.
     *   - Single chat: otherwise (no colon in text). The title (or "未知" if
     *     null/blank) is the sender; the whole text is the content.
     */
    fun parse(title: String?, text: String?, pkg: String): ParsedNotification? {
        if (pkg !in TARGET_PACKAGES) return null
        if (text.isNullOrBlank()) return null
        val t = title?.trim().orEmpty()
        val trimmedText = text.trim()
        val groupMatch = Regex("^(.*)\\((\\d+)\\)$").find(t)
        val hasColon = trimmedText.indexOf(':') >= 0 || trimmedText.indexOf('：') >= 0

        return if (groupMatch != null) {
            // Case A: explicit unread-count parens in the title.
            val groupName = groupMatch.groupValues[1].trim()
            val (sender, content) = splitSenderContent(trimmedText, "未知")
            ParsedNotification(
                appId = pkg,
                groupId = groupId(pkg, groupName),
                groupName = groupName,
                senderName = sender,
                content = content,
                isGroup = true,
            )
        } else if (t.isNotEmpty() && hasColon) {
            // Case B: bare group-name title + "sender:content" text.
            val (sender, content) = splitSenderContent(trimmedText, "未知")
            ParsedNotification(
                appId = pkg,
                groupId = groupId(pkg, t),
                groupName = t,
                senderName = sender,
                content = content,
                isGroup = true,
            )
        } else {
            // Single chat: title is the sender; whole text is the content.
            val sender = if (t.isEmpty()) "未知" else t
            ParsedNotification(
                appId = pkg,
                groupId = groupId(pkg, sender),
                groupName = null,
                senderName = sender,
                content = trimmedText,
                isGroup = false,
            )
        }
    }

    /**
     * Split "sender: content" on the first colon (ASCII ':' or fullwidth '：'),
     * with optional surrounding spaces. If no colon, the whole text is the
     * content and [defaultSender] is returned as the sender ("未知" by default).
     */
    private fun splitSenderContent(text: String, defaultSender: String = "未知"): Pair<String, String> {
        // find first ':' or '：'
        val idx = listOf(text.indexOf(':'), text.indexOf('：')).filter { it >= 0 }.minOrNull()
            ?: return defaultSender to text
        // Strip a leading "[N条]" / "[N条新消息]" aggregate-count prefix from the
        // sender, so "@<sender>" composition doesn't include the count token.
        // e.g. "[2条]王师傅: ..." → sender "王师傅" (not "[2条]王师傅").
        val senderRaw = text.substring(0, idx).trim().ifEmpty { return defaultSender to text.substring(idx + 1).trim() }
        val sender = Regex("^\\[\\d+条(新消息)?\\]").replace(senderRaw, "").trim().ifEmpty { defaultSender }
        val content = text.substring(idx + 1).trim()
        return sender to content
    }

    /** Stable 16-hex-char pseudo id from appId + name (sha1, truncated). */
    private fun groupId(appId: String, name: String): String {
        val md = MessageDigest.getInstance("SHA-1")
        val raw = "$appId|$name"
        return md.digest(raw.toByteArray(Charsets.UTF_8))
            .joinToString("") { "%02x".format(it) }
            .substring(0, 16)
    }
}
