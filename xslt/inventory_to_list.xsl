<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0"
    xmlns:cts="http://chs.harvard.edu/xmlns/cts3/ti" exclude-result-prefixes="cts">
    
    <xsl:output method="html" indent="yes" xml:space="default"/>
    
    <xsl:param name="e_lang" select="'eng'"/>
    <xsl:variable name="apos">'</xsl:variable>
    <xsl:variable name="apos_replace" select="concat('\',$apos)"/>
    
    
    <xsl:template match="/">
        <html>
            <head><title>Available Texts</title></head>
            <link rel="stylesheet" type="text/css" href="../css/ctsworklist.css"></link>
            <body>
                <!--start inventory obj -->
                <ul class="textgroup">
                    <xsl:for-each select="//cts:textgroup">
                        <xsl:sort select="cts:groupname"/>
                        <xsl:variable name="group" select="normalize-space(@projid)"/>
                        <xsl:variable name="groupname" select="normalize-space(cts:groupname[1])"/>
                        <xsl:variable name="group_prefix" select="normalize-space(substring-before($group,':'))"/>
                        <xsl:variable name="key" select="$group"/>
                        
                        <!-- iterate through works -->
                        <xsl:if test="cts:work/cts:edition/cts:online">
                            <li><label for="{$group}"><xsl:value-of select="$groupname"/></label>
                                <input type="checkbox" id="{$group}" />
                                <ul>
                                    <xsl:for-each select="cts:work">
                                        <xsl:sort select="cts:title"/>
                                        <xsl:apply-templates select="."/>
                                    </xsl:for-each>
                                </ul>
                            </li>    
                        </xsl:if>
                    </xsl:for-each>
                </ul>        
            </body>
        </html>
    </xsl:template>
    
    <xsl:template match="cts:work">
        <xsl:variable name="group" select="normalize-space(parent::cts:textgroup/@projid)"/>
        <xsl:variable name="groupname" select="normalize-space(parent::cts:textgroup/cts:groupname[1])"/>
        <xsl:variable name="group_prefix" select="normalize-space(substring-before($group,':'))"/>
        <xsl:variable name="work_prefix" select="normalize-space(substring-before(@projid,':'))"/>
        <xsl:variable name="work">
            <xsl:choose>
                <xsl:when test="$work_prefix = $group_prefix">
                    <xsl:value-of select="normalize-space(substring-after(@projid,':'))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="normalize-space(@projid)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="key" select="$work"/>
        <xsl:variable name="urn" select="concat($group,'.',$work)"/>
        <xsl:variable name="label">
            <xsl:choose>
                <xsl:when test="$e_lang and cts:title[@xml:lang=$e_lang]">
                    <xsl:call-template name="replace-string">
                        <xsl:with-param name="text" select="normalize-space(cts:title[@xml:lang=$e_lang])"/>
                        <xsl:with-param name="replace" select="$apos"/>
                        <xsl:with-param name="with" select="$apos_replace"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="cts:title">
                    <xsl:call-template name="replace-string">
                        <xsl:with-param name="text" select="translate(normalize-space(cts:title[1]),':',',')"/>
                        <xsl:with-param name="replace" select="$apos"/>
                        <xsl:with-param name="with" select="$apos_replace"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="normalize-space(substring-after(@projid,':'))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <!-- start work obj -->
        
        <xsl:if test="cts:edition[cts:online]">
            <li class="work"><span class="worktitle"><xsl:value-of select="$label"/></span>
            <!-- add translations field -->
            <xsl:if test="cts:translation[cts:online]">
                <span class="translation"> (translation available)</span>
            </xsl:if>
            </li>            
        </xsl:if>
    </xsl:template>
    
    
    <xsl:template name="citation">
    <xsl:param name="a_node"/>
    <xsl:text>"</xsl:text><xsl:value-of select="normalize-space($a_node/@label)"/><xsl:text>"</xsl:text>
    <xsl:if test="$a_node/cts:citation">
        <xsl:text>,</xsl:text>
        <xsl:call-template name="citation">
            <xsl:with-param name="a_node" select="$a_node/cts:citation"/>
        </xsl:call-template>
    </xsl:if>
    </xsl:template>
    
    <xsl:template match="*"/>
    
    <xsl:template name="replace-string">
        <xsl:param name="text"/>
        <xsl:param name="replace"/>
        <xsl:param name="with"/>
        <xsl:choose>
            <xsl:when test="contains($text,$replace)">
                <xsl:value-of select="substring-before($text,$replace)"/>
                <xsl:value-of select="$with"/>
                <xsl:call-template name="replace-string">
                    <xsl:with-param name="text"
                        select="substring-after($text,$replace)"/>
                    <xsl:with-param name="replace" select="$replace"/>
                    <xsl:with-param name="with" select="$with"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>