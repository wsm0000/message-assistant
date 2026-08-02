package com.example.message_assistant

import org.junit.Assert.*
import org.junit.Test

class NotificationParserTest {
    @Test fun groupMessage_parsesTitleAndSender() {
        val r = NotificationParser.parse("货运华东群(3)", "王师傅: 南京到上海", "com.tencent.mm")
        assertNotNull(r)
        assertEquals("货运华东群", r!!.groupName)
        assertEquals("王师傅", r.senderName)
        assertEquals("南京到上海", r.content)
        assertTrue(r.isGroup)
    }
    @Test fun singleChat_titleHasNoBrackets() {
        val r = NotificationParser.parse("王师傅", "南京到上海", "com.tencent.mm")
        assertNotNull(r)
        assertEquals("王师傅", r!!.senderName)
        assertEquals("南京到上海", r.content)
        assertFalse(r.isGroup)
    }
    @Test fun aggregatedMessage_keepsVisibleContent() {
        val r = NotificationParser.parse("货运华东群", "[3条]王师傅: 南京到上海", "com.tencent.mm")
        assertNotNull(r)
        assertTrue(r!!.content.contains("南京到上海"))
    }
    @Test fun nonTargetPackage_returnsNull() {
        val r = NotificationParser.parse("货运华东群", "x", "com.other.app")
        assertNull(r)
    }
    @Test fun emptyText_returnsNull() {
        val r = NotificationParser.parse("货运华东群", "", "com.tencent.mm")
        assertNull(r)
    }
    @Test fun blankText_returnsNull() {
        val r = NotificationParser.parse("货运华东群", "   ", "com.tencent.mm")
        assertNull(r)
    }
    @Test fun nullTitle_singleChatTreatsUnknownSender() {
        val r = NotificationParser.parse(null, "南京到上海", "com.tencent.mm")
        assertNotNull(r)
        assertEquals("南京到上海", r!!.content)
        assertFalse(r.isGroup)
    }
    @Test fun noColonInText_wholeTextIsContent() {
        val r = NotificationParser.parse("货运华东群", "整段无冒号", "com.tencent.mm")
        assertNotNull(r)
        assertEquals("整段无冒号", r!!.content)
    }
    @Test fun groupId_isStableHashOfAppAndGroup() {
        val a = NotificationParser.parse("货运华东群", "王: x", "com.tencent.mm")!!
        val b = NotificationParser.parse("货运华东群(9)", "李: y", "com.tencent.mm")!!
        assertEquals(a.groupId, b.groupId)
    }
    @Test fun groupId_is16CharHex() {
        val r = NotificationParser.parse("货运华东群", "王: x", "com.tencent.mm")!!
        assertTrue("groupId should be 16 hex chars, was: ${r.groupId}", Regex("^[0-9a-f]{16}$").matches(r.groupId))
    }
    @Test fun singleChat_groupIdHashesAppAndSender() {
        val r = NotificationParser.parse("王师傅", "hi", "com.tencent.mm")!!
        // single chat: groupId derived from app + senderName (no group)
        assertFalse(r.isGroup)
        assertTrue(r.groupId.isNotEmpty())
    }
    @Test fun colonWithoutSpaceAlsoSplits() {
        // some WeChat variants use "王师傅:消息" with a fullwidth or no space; be lenient
        val r = NotificationParser.parse("群", "王师傅:南京到上海", "com.tencent.mm")
        assertNotNull(r)
        assertEquals("王师傅", r!!.senderName)
        assertEquals("南京到上海", r.content)
    }

    @Test fun aggregatePrefix_strippedFromSender() {
        // "[2条]Nemo_船长: ..." → sender "Nemo_船长" (NOT "[2条]Nemo_船长")
        val r = NotificationParser.parse("货运群", "[2条]Nemo_船长: 南京到上海", "com.tencent.mm")
        assertNotNull(r)
        assertEquals("Nemo_船长", r!!.senderName)
        assertEquals("南京到上海", r.content)
    }

    @Test fun aggregatePrefix_newMessagesVariant_strippedFromSender() {
        // "[3条新消息]王师傅: ..." → sender "王师傅"
        val r = NotificationParser.parse("货运群", "[3条新消息]王师傅: 发车", "com.tencent.mm")
        assertNotNull(r)
        assertEquals("王师傅", r!!.senderName)
        assertEquals("发车", r.content)
    }
}
