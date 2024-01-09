<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:pc="http://schema.primaresearch.org/PAGE/gts/pagecontent/2019-07-15"
    xmlns:pt="http://schema.primaresearch.org/PAGE/gts/pagecontent/2013-07-15"
    xmlns:in="http://www.intern.de"
    xmlns:gt="http://www.ocr-d.de/GT/"
    xmlns:mets="http://www.loc.gov/METS/"
    xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:ns3="http://www.loc.gov/METS/"
    exclude-result-prefixes="#all"
    version="3.0">
    <xsl:output indent="yes" omit-xml-declaration="yes" method="xml"/>
    <xsl:import href="LevelGtStructure.xsl"/>
    
    <xsl:param name="repoName"/>
    <xsl:param name="repoBase"/>
    <xsl:param name="bagitDumpNum"/>
    <xsl:param name="releaseTag"/>
    <xsl:param name="rulesetxml">megalevelrules.xml</xsl:param>
    <xsl:param name="rulesetPath">..</xsl:param>
    
    
    <xsl:variable name="ruleset">
        <xsl:copy-of select="document($rulesetPath/$rulesetxml)"/>
    </xsl:variable>

    <xsl:variable name="docMETADATA">
        <xsl:copy-of select="json-to-xml(unparsed-text('../METADATA.json'))"/>
    </xsl:variable>

    <xsl:variable name="gtFormat" select="$docMETADATA//fn:map/fn:string[@key='format']"/>

    <xsl:variable name="path">
        <xsl:if test="$docMETADATA//fn:map/fn:string[@key/contains(.,'gtTyp')]/text() = 'data_document'">../data_document</xsl:if>
        <xsl:if test="$docMETADATA//fn:map/fn:string[@key/contains(.,'gtTyp')]/text() = 'data_structure'">../data</xsl:if>
        <xsl:if test="$docMETADATA//fn:map/fn:string[@key/contains(.,'gtTyp')]/text() = 'data_structure_and_text'">../data</xsl:if>
        <xsl:if test="$docMETADATA//fn:map/fn:string[@key/contains(.,'gtTyp')]/text() = 'data_line'">../data</xsl:if>
    </xsl:variable>
    <xsl:variable name="coll"><xsl:value-of select="$path"/>/?select=*.xml;recurse=yes</xsl:variable>
    <xsl:variable name="gtTypPath" select="replace($path, '../(.+)', '$1/')"/>

    <xsl:variable name="holeRuleMetric">
        <xsl:for-each select="collection($coll)">
        <xsl:variable name="filename" select="base-uri()" />
        
        
        <xsl:variable name="gtdocument">
            <xsl:if test="$gtFormat = 'Page-XML'"><xsl:value-of select="substring-after(substring-before($filename, '/GT-PAGE/')[1],$gtTypPath)"/></xsl:if>
        </xsl:variable>
        
        <xsl:if test="$gtdocument !=''">
                <volumename><xsl:value-of select="substring-after(substring-before($filename, '/GT-PAGE/')[1], 'data/')"/></volumename> 
                <page><xsl:value-of select="substring-after($filename, '/GT-PAGE/')"/></page>
        </xsl:if>
        </xsl:for-each>
    </xsl:variable>
    
    <xsl:variable name="vurl" select="$docMETADATA//*[not(ancestor::fn:array[@key='license'])]/fn:string[@key='url']"/>
    
    

    <xsl:template match="/">
        
        <xsl:variable name="tablepage">
         <xsl:for-each select="collection($coll)">
            <xsl:variable name="filename" select="base-uri()" />
            <xsl:choose>
                        <xsl:when test="document($filename)//pc:PcGts/pc:Page/pc:TextRegion/pc:TextEquiv/pc:Unicode/text() !='' or document($filename)//pt:PcGts/pt:Page/pt:TextRegion/pt:TextEquiv/pt:Unicode/text() !=''">
                            <xsl:variable name="numFile">
                                <pc:tst>
                                    <xsl:for-each select="document($filename)//pc:PcGts">
                                        
                                        <pc:File><xsl:number count="."/>--<xsl:value-of select="normalize-space(.)"/></pc:File>
                                    </xsl:for-each>
                                    <xsl:for-each select="document($filename)//pt:PcGts">
                                        <pc:File><xsl:value-of select="normalize-space(.)"/></pc:File>
                                    </xsl:for-each>
                                </pc:tst>
                             </xsl:variable>
                            <xsl:variable name="TextRegionUnicode">
                                <pc:Unicode>
                                    <xsl:for-each select="document($filename)//pc:PcGts/pc:Page/pc:TextRegion/pc:TextEquiv/pc:Unicode">
                                        <xsl:value-of select="normalize-space(.)"/>
                                    </xsl:for-each>
                                    <xsl:for-each select="document($filename)//pt:PcGts/pt:Page/pt:TextRegion/pt:TextEquiv/pt:Unicode">
                                        <xsl:value-of select="normalize-space(.)"/>
                                    </xsl:for-each>
                                </pc:Unicode>
                            </xsl:variable>
                            
                            
                            <xsl:variable name="leveltable">
                                <details>
                                  <xsl:variable name="levels">
                                    <xsl:for-each select="$ruleset//ruleset">
                                        <xsl:variable name="rdesc" select="desc"/>
                                        <xsl:variable name="l1" select="rule[1]"/>
                                        <xsl:variable name="l2" select="rule[2]"/>
                                        <xsl:variable name="l3" select="rule[3]"/>
                                        <xsl:variable name="pattern" select="'(.)\1'" />
                                        
                                        
                                        
                                        <xsl:variable name="test">
                                            <xsl:for-each select="matches($l1, $pattern)">
                                                <xsl:value-of select="." />
                                            </xsl:for-each>
                                        </xsl:variable>
                                        <xsl:choose>
                                            <xsl:when test="$l1 = $l2 and $l2 = $l3 "/>
                                            <xsl:otherwise>
                                                <xsl:variable name="trLevel">
                                                <tr>
                                                    <xsl:attribute name="title"><xsl:value-of select="$rdesc"/></xsl:attribute>
                                                    <td class="l1"><xsl:choose>
                                                        <xsl:when test="$test ='true'">
                                                            <xsl:attribute name="char"><xsl:value-of select="$l1"/></xsl:attribute><xsl:value-of select="(string-length($TextRegionUnicode) - string-length(replace($TextRegionUnicode, $l1, '')))" />
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:choose>
                                                                <xsl:when test="$l1 !=''">
                                                                    <xsl:attribute name="char"><xsl:value-of select="$l1"/></xsl:attribute><xsl:value-of select="string-length($TextRegionUnicode) - string-length(replace($TextRegionUnicode, $l1, ''))" />
                                                                </xsl:when><xsl:otherwise><xsl:attribute name="char">[N. N.]</xsl:attribute>0</xsl:otherwise>
                                                            </xsl:choose>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                    </td>
                                                    <td class="l2"><xsl:attribute name="char"><xsl:value-of select="$l2"/></xsl:attribute><xsl:value-of select="string-length($TextRegionUnicode) - string-length(replace($TextRegionUnicode, $l2, ''))" /></td>
                                                    <td class="l3"><xsl:attribute name="char"><xsl:value-of select="$l3"/></xsl:attribute><xsl:value-of select="string-length($TextRegionUnicode) - string-length(replace($TextRegionUnicode, $l3, ''))" /></td>
                                                </tr>
                                                </xsl:variable>
                                               <xsl:choose>
                                                   <xsl:when test="$trLevel//td[@class='l1'] = $trLevel//td[@class='l2'] and $trLevel//td[@class='l2'] = $trLevel//td[@class='l3']"/>
                                                   <xsl:otherwise><xsl:copy-of select="$trLevel"/></xsl:otherwise>
                                               </xsl:choose>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        
                                        
                                        
                                    </xsl:for-each>
                                </xsl:variable>
                                
                                
                                <xsl:variable name="sumlevel1" select="sum($levels//tr/td[@class='l1'])"/>
                                <xsl:variable name="sumlevel2" select="sum($levels//tr/td[@class='l2'])"/>
                                <xsl:variable name="sumlevel3" select="sum($levels//tr/td[@class='l3'])"/>
                                <xsl:variable name="sumlevel1_2" select="sum($sumlevel1, $sumlevel2)"/>
                                <xsl:variable name="sumlevel2_3" select="sum($sumlevel2, $sumlevel3)"/>
                                
                                
                                 <summary>Level Matrix Page: <xsl:value-of select="substring-after($filename, '/GT-PAGE/')"/></summary>
                                 <table class="pagelevel">
                                     <tr><td class="dname" colspan="2"><xsl:value-of select="substring-after($filename, '/GT-PAGE/')"/></td></tr>
                                     <tr><td class="sumchar" colspan="2"><xsl:value-of select="string-length(translate($TextRegionUnicode, ' ', ''))"/></td></tr>
                                <tr class="suml">
                                   <td class="sl1"><xsl:value-of select="$sumlevel1"/></td>
                                   <td class="sl2"><xsl:value-of select="$sumlevel2"/></td>
                                   <td class="sl3"><xsl:value-of select="$sumlevel3"/></td>
                                </tr>
                                <tr>
                                    <xsl:choose>
                                        <xsl:when test="$sumlevel1 &gt;= $sumlevel2 and $sumlevel1 &gt;= $sumlevel3 and $sumlevel1 &gt;= ($sumlevel2 + $sumlevel3)">
                                            <td class="leveldesc">
                                                <button type="button" class="bilanguage" onclick="changeLanguage()" data-en="Deutsch" data-de="English"><xsl:text> </xsl:text></button>
                                                <p class="bilanguage" data-de="Transkription entspricht dem Level 1" data-en="Transcription corresponds to level 1"/><span class="level">1</span>
                                                <ul><li><a href="https://ocr-d.de/en/gt-guidelines/trans/trGrundsaetze.html"><span class="bilanguage" data-de="Allgemeines zu den Transkriptionslevel" data-en="General explanation of the ground truth levels"/></a></li>
                                                    <li><a href="https://ocr-d.de/en/gt-guidelines/trans/tr_level_1_4.html"><span class="bilanguage" data-de="Wie wird im Level 1 transkribiert." data-en="How to transcribe in Level 1."/></a></li></ul></td>
                                        </xsl:when>
                                        <xsl:when test="$sumlevel2 &gt;= $sumlevel1 and $sumlevel2 &gt; $sumlevel3">
                                            <td  class="leveldesc">
                                                <button type="button" class="bilanguage" onclick="changeLanguage()" data-en="Deutsch" data-de="English"><xsl:text> </xsl:text></button>
                                                <p class="bilanguage" data-de="Transkription entspricht dem Level 2" data-en="Transcription corresponds to level 2"/><span class="level">2</span>
                                                <ul><li><a href="https://ocr-d.de/en/gt-guidelines/trans/trGrundsaetze.html"><span class="bilanguage" data-de="Allgemeines zu den Transkriptionslevel" data-en="General explanation of the ground truth levels"/></a></li>
                                                    <li><a href="https://ocr-d.de/en/gt-guidelines/trans/tr_level_2_4.html"><span class="bilanguage" data-de="Wie wird im Level 2 transkribiert." data-en="How to transcribe in Level 2."/></a></li></ul></td>
                                        </xsl:when>
                                        <xsl:when test="$sumlevel2 = $sumlevel1 and $sumlevel2 = $sumlevel3">
                                            <td  class="leveldesc">
                                                <button type="button" class="bilanguage" onclick="changeLanguage()" data-en="Deutsch" data-de="English"><xsl:text> </xsl:text></button>
                                                <p class="bilanguage" data-de="Transkription entspricht dem Level 1, 2, 3" data-en="Transcription corresponds to levels 1, 2, 3"/><span class="level">6</span>
                                                <ul><li><a href="https://ocr-d.de/en/gt-guidelines/trans/trGrundsaetze.html"><span class="bilanguage" data-de="Allgemeines zu den Transkriptionslevel" data-en="General explanation of the ground truth levels"/></a></li></ul></td>
                                        </xsl:when>
                                        <xsl:when test="$sumlevel2 &gt;= $sumlevel1 and $sumlevel2 &gt;= $sumlevel3">
                                            <td  class="leveldesc">
                                                <button type="button" class="bilanguage" onclick="changeLanguage()" data-en="Deutsch" data-de="English"><xsl:text> </xsl:text></button>
                                                <p class="bilanguage" data-de="Transkription entspricht dem Level 2 und Level 3" data-en="Transcription corresponds to level 2 and level 3"/><span class="level">5</span>
                                                <ul><li><a href="https://ocr-d.de/en/gt-guidelines/trans/trGrundsaetze.html"><span class="bilanguage" data-de="Allgemeines zu den Transkriptionslevel" data-en="General explanation of the ground truth levels"/></a></li>
                                                    <li><a href="https://ocr-d.de/en/gt-guidelines/trans/tr_level_2_4.html"><span class="bilanguage" data-de="Wie wird im Level 2 transkribiert." data-en="How to transcribe in Level 2."/></a></li>
                                                    <li><a href="https://ocr-d.de/en/gt-guidelines/trans/tr_level_3_4.html"><span class="bilanguage" data-de="Wie wird im Level 3 transkribiert." data-en="How to transcribe in Level 3."/></a></li></ul></td>
                                        </xsl:when>
                                        <xsl:when test="$sumlevel1_2  &gt; $sumlevel2_3">
                                            <td  class="leveldesc">
                                                <button type="button" class="bilanguage" onclick="changeLanguage()" data-en="Deutsch" data-de="English"><xsl:text> </xsl:text></button>
                                                <p class="bilanguage" data-de="Transkription entspricht dem Level 1 und Level 2" data-en="Transcription corresponds to level 1 and level 2"/><span class="level">4</span>
                                                <ul><li><a href="https://ocr-d.de/en/gt-guidelines/trans/trGrundsaetze.html"><span class="bilanguage" data-de="Allgemeines zu den Transkriptionslevel" data-en="General explanation of the ground truth levels"/></a></li>
                                                    <li><a href="https://ocr-d.de/en/gt-guidelines/trans/tr_level_1_4.html"><span class="bilanguage" data-de="Wie wird im Level 1 transkribiert." data-en="How to transcribe in Level 1."/></a></li>
                                                    <li><a href="https://ocr-d.de/en/gt-guidelines/trans/tr_level_2_4.html"><span class="bilanguage" data-de="Wie wird im Level 2 transkribiert." data-en="How to transcribe in Level 2."/></a></li></ul></td>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <td  class="leveldesc">
                                                <button type="button" class="bilanguage" onclick="changeLanguage()" data-en="Deutsch" data-de="English"><xsl:text> </xsl:text></button>
                                                <p class="bilanguage" data-de="Transkription entspricht dem Level 3" data-en="Transcription corresponds to level 3"/><span class="level">3</span>
                                                <ul><li><a href="https://ocr-d.de/en/gt-guidelines/trans/trGrundsaetze.html"><span class="bilanguage" data-de="Allgemeines zu den Transkriptionslevel" data-en="General explanation of the ground truth levels"/></a></li>
                                                    <li><a href="https://ocr-d.de/en/gt-guidelines/trans/tr_level_3_4.html"><span class="bilanguage" data-de="Wie wird im Level 3 transkribiert." data-en="How to transcribe in Level 3."/></a></li></ul></td>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </tr>
                                
                                <xsl:copy-of select="$levels"/>
                                 </table>
                            </details>
                            </xsl:variable>
                        <xsl:copy-of select="$leveltable"/>
                        </xsl:when>
                        



                        <xsl:otherwise>
                            <xsl:choose>
                                
                                <xsl:when test="document($filename)//pc:PcGts/pc:Page/pc:TextRegion/pc:TextLine/pc:TextEquiv/pc:Unicode/text() or document($filename)//pt:PcGts/pt:Page/pt:TextRegion/pt:TextLine/pt:TextEquiv/pt:Unicode/text()">
                                        <xsl:variable name="numFile">
                                            <pc:tst>
                                                <xsl:for-each select="document($filename)//pc:PcGts">
                                                    
                                                    <pc:File><xsl:number count="."/>--<xsl:value-of select="normalize-space(.)"/></pc:File>
                                                </xsl:for-each>
                                                <xsl:for-each select="document($filename)//pt:PcGts">
                                                    <pc:File><xsl:value-of select="normalize-space(.)"/></pc:File>
                                                </xsl:for-each>
                                            </pc:tst>
                                        </xsl:variable>
                                        <xsl:variable name="TextRegionUnicode">
                                            <pc:Unicode>
                                                <xsl:for-each select="document($filename)//pc:PcGts/pc:Page/pc:TextRegion/pc:TextLine/pc:TextEquiv/pc:Unicode">
                                                    <xsl:value-of select="normalize-space(.)"/>
                                                </xsl:for-each>
                                                <xsl:for-each select="document($filename)//pt:PcGts/pt:Page/pt:TextRegion/pt:TextLine/pt:TextEquiv/pt:Unicode">
                                                    <xsl:value-of select="normalize-space(.)"/>
                                                </xsl:for-each>
                                            </pc:Unicode>
                                        </xsl:variable>
                                        
                                        
                                        <xsl:variable name="leveltable">
                                            <details>
                                                <xsl:variable name="levels">
                                                    <xsl:for-each select="$ruleset//ruleset">
                                                        <xsl:variable name="rdesc" select="desc"/>
                                                        <xsl:variable name="l1" select="rule[1]"/>
                                                        <xsl:variable name="l2" select="rule[2]"/>
                                                        <xsl:variable name="l3" select="rule[3]"/>
                                                        <xsl:variable name="pattern" select="'(.)\1'" />
                                                        
                                                        
                                                        
                                                        <xsl:variable name="test">
                                                            <xsl:for-each select="matches($l1, $pattern)">
                                                                <xsl:value-of select="." />
                                                            </xsl:for-each>
                                                        </xsl:variable>
                                                        <xsl:choose>
                                                            <xsl:when test="$l1 = $l2 and $l2 = $l3 "/>
                                                            <xsl:otherwise>
                                                                <xsl:variable name="trLevel">
                                                                    <tr>
                                                                        <xsl:attribute name="title"><xsl:value-of select="$rdesc"/></xsl:attribute>
                                                                        <td class="l1"><xsl:choose>
                                                                            <xsl:when test="$test ='true'">
                                                                                <xsl:attribute name="char"><xsl:value-of select="$l1"/></xsl:attribute><xsl:value-of select="(string-length($TextRegionUnicode) - string-length(replace($TextRegionUnicode, $l1, '')))" />
                                                                            </xsl:when>
                                                                            <xsl:otherwise>
                                                                                <xsl:choose>
                                                                                    <xsl:when test="$l1 !=''">
                                                                                        <xsl:attribute name="char"><xsl:value-of select="$l1"/></xsl:attribute><xsl:value-of select="string-length($TextRegionUnicode) - string-length(replace($TextRegionUnicode, $l1, ''))" />
                                                                                    </xsl:when><xsl:otherwise><xsl:attribute name="char">[N. N.]</xsl:attribute>0</xsl:otherwise>
                                                                                </xsl:choose>
                                                                            </xsl:otherwise>
                                                                        </xsl:choose>
                                                                        </td>
                                                                        <td class="l2"><xsl:attribute name="char"><xsl:value-of select="$l2"/></xsl:attribute><xsl:value-of select="string-length($TextRegionUnicode) - string-length(replace($TextRegionUnicode, $l2, ''))" /></td>
                                                                        <td class="l3"><xsl:attribute name="char"><xsl:value-of select="$l3"/></xsl:attribute><xsl:value-of select="string-length($TextRegionUnicode) - string-length(replace($TextRegionUnicode, $l3, ''))" /></td>
                                                                    </tr>
                                                                </xsl:variable>
                                                                <xsl:choose>
                                                                    <xsl:when test="$trLevel//td[@class='l1'] = $trLevel//td[@class='l2'] and $trLevel//td[@class='l2'] = $trLevel//td[@class='l3']"/>
                                                                    <xsl:otherwise><xsl:copy-of select="$trLevel"/></xsl:otherwise>
                                                                </xsl:choose>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                        
                                                        
                                                        
                                                    </xsl:for-each>
                                                </xsl:variable>
                                                
                                                
                                                <xsl:variable name="sumlevel1" select="sum($levels//tr/td[@class='l1'])"/>
                                                <xsl:variable name="sumlevel2" select="sum($levels//tr/td[@class='l2'])"/>
                                                <xsl:variable name="sumlevel3" select="sum($levels//tr/td[@class='l3'])"/>
                                                <xsl:variable name="sumlevel1_2" select="sum($sumlevel1, $sumlevel2)"/>
                                                <xsl:variable name="sumlevel2_3" select="sum($sumlevel2, $sumlevel3)"/>
                                                
                                                
                                                <summary>Level Matrix Page: <xsl:value-of select="substring-after($filename, '/GT-PAGE/')"/></summary>
                                                <table class="pagelevel">
                                                    <tr><td class="dname" colspan="2"><xsl:value-of select="substring-after($filename, '/GT-PAGE/')"/></td></tr>
                                                    <tr><td class="sumchar" colspan="2"><xsl:value-of select="string-length(translate($TextRegionUnicode, ' ', ''))"/></td></tr>
                                                    <tr class="suml">
                                                        <td class="sl1"><xsl:value-of select="$sumlevel1"/></td>
                                                        <td class="sl2"><xsl:value-of select="$sumlevel2"/></td>
                                                        <td class="sl3"><xsl:value-of select="$sumlevel3"/></td>
                                                    </tr>
                                                    <tr>
                                                        <xsl:choose>
                                                            <xsl:when test="$sumlevel1 &gt;= $sumlevel2 and $sumlevel1 &gt;= $sumlevel3 and $sumlevel1 &gt;= ($sumlevel2 + $sumlevel3)">
                                                                <td  class="leveldesc">
                                                                    <button type="button" class="bilanguage" onclick="changeLanguage()" data-en="Deutsch" data-de="English"><xsl:text> </xsl:text></button>
                                                                    <p class="bilanguage" data-de="Transkription entspricht dem Level 1" data-en="Transcription corresponds to level 1"/><span class="level">1</span>
                                                                    <ul><li><a href="https://ocr-d.de/en/gt-guidelines/trans/trGrundsaetze.html"><span class="bilanguage" data-de="Allgemeines zu den Transkriptionslevel" data-en="General explanation of the ground truth levels"/></a></li>
                                                                        <li><a href="https://ocr-d.de/en/gt-guidelines/trans/tr_level_1_4.html"><span class="bilanguage" data-de="Wie wird im Level 1 transkribiert." data-en="How to transcribe in Level 1."/></a></li></ul></td>
                                                            </xsl:when>
                                                            <xsl:when test="$sumlevel2 &gt;= $sumlevel1 and $sumlevel2 &gt; $sumlevel3">
                                                                <td  class="leveldesc">
                                                                    <button type="button" class="bilanguage" onclick="changeLanguage()" data-en="Deutsch" data-de="English"><xsl:text> </xsl:text></button>
                                                                    <p class="bilanguage" data-de="Transkription entspricht dem Level 2" data-en="Transcription corresponds to level 2"/><span class="level">2</span>
                                                                    <ul><li><a href="https://ocr-d.de/en/gt-guidelines/trans/trGrundsaetze.html"><span class="bilanguage" data-de="Allgemeines zu den Transkriptionslevel" data-en="General explanation of the ground truth levels"/></a></li>
                                                                        <li><a href="https://ocr-d.de/en/gt-guidelines/trans/tr_level_2_4.html"><span class="bilanguage" data-de="Wie wird im Level 2 transkribiert." data-en="How to transcribe in Level 2."/></a></li></ul></td>
                                                            </xsl:when>
                                                            <xsl:when test="$sumlevel2 = $sumlevel1 and $sumlevel2 = $sumlevel3">
                                                                <td  class="leveldesc">
                                                                    <button type="button" class="bilanguage" onclick="changeLanguage()" data-en="Deutsch" data-de="English"><xsl:text> </xsl:text></button>
                                                                    <p class="bilanguage" data-de="Transkription entspricht dem Level 1, 2, 3" data-en="Transcription corresponds to levels 1, 2, 3"/><span class="level">6</span>
                                                                    <ul><li><a href="https://ocr-d.de/en/gt-guidelines/trans/trGrundsaetze.html"><span class="bilanguage" data-de="Allgemeines zu den Transkriptionslevel" data-en="General explanation of the ground truth levels"/></a></li></ul></td>
                                                            </xsl:when>
                                                            <xsl:when test="$sumlevel2 &gt;= $sumlevel1 and $sumlevel2 &gt;= $sumlevel3">
                                                                <td  class="leveldesc">
                                                                    <button type="button" class="bilanguage" onclick="changeLanguage()" data-en="Deutsch" data-de="English"><xsl:text> </xsl:text></button>
                                                                    <p class="bilanguage" data-de="Transkription entspricht dem Level 2 und Level 3" data-en="Transcription corresponds to level 2 and level 3"/><span class="level">5</span>
                                                                    <ul><li><a href="https://ocr-d.de/en/gt-guidelines/trans/trGrundsaetze.html"><span class="bilanguage" data-de="Allgemeines zu den Transkriptionslevel" data-en="General explanation of the ground truth levels"/></a></li>
                                                                        <li><a href="https://ocr-d.de/en/gt-guidelines/trans/tr_level_2_4.html"><span class="bilanguage" data-de="Wie wird im Level 2 transkribiert." data-en="How to transcribe in Level 2."/></a></li>
                                                                        <li><a href="https://ocr-d.de/en/gt-guidelines/trans/tr_level_3_4.html"><span class="bilanguage" data-de="Wie wird im Level 3 transkribiert." data-en="How to transcribe in Level 3."/></a></li></ul></td>
                                                            </xsl:when>
                                                            <xsl:when test="$sumlevel1_2  &gt; $sumlevel2_3">
                                                                <td  class="leveldesc">
                                                                    <button type="button" class="bilanguage" onclick="changeLanguage()" data-en="Deutsch" data-de="English"><xsl:text> </xsl:text></button>
                                                                    <p class="bilanguage" data-de="Transkription entspricht dem Level 1 und Level 2" data-en="Transcription corresponds to level 1 and level 2"/><span class="level">4</span>
                                                                    <ul><li><a href="https://ocr-d.de/en/gt-guidelines/trans/trGrundsaetze.html"><span class="bilanguage" data-de="Allgemeines zu den Transkriptionslevel" data-en="General explanation of the ground truth levels"/></a></li>
                                                                        <li><a href="https://ocr-d.de/en/gt-guidelines/trans/tr_level_1_4.html"><span class="bilanguage" data-de="Wie wird im Level 1 transkribiert." data-en="How to transcribe in Level 1."/></a></li>
                                                                        <li><a href="https://ocr-d.de/en/gt-guidelines/trans/tr_level_2_4.html"><span class="bilanguage" data-de="Wie wird im Level 2 transkribiert." data-en="How to transcribe in Level 2."/></a></li></ul></td>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <td  class="leveldesc">
                                                                    <button type="button" class="bilanguage" onclick="changeLanguage()" data-en="Deutsch" data-de="English"><xsl:text> </xsl:text></button>
                                                                    <p class="bilanguage" data-de="Transkription entspricht dem Level 3" data-en="Transcription corresponds to level 3"/><span class="level">3</span>
                                                                    <ul><li><a href="https://ocr-d.de/en/gt-guidelines/trans/trGrundsaetze.html"><span class="bilanguage" data-de="Allgemeines zu den Transkriptionslevel" data-en="General explanation of the ground truth levels"/></a></li>
                                                                        <li><a href="https://ocr-d.de/en/gt-guidelines/trans/tr_level_3_4.html"><span class="bilanguage" data-de="Wie wird im Level 3 transkribiert." data-en="How to transcribe in Level 3."/></a></li></ul></td>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </tr>
                                                    
                                                    <xsl:copy-of select="$levels"/>
                                                </table>
                                            </details>
                                        </xsl:variable>
                                        <xsl:copy-of select="$leveltable"/>
                                    </xsl:when>
                                    
                                    
                                <xsl:otherwise/>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
       </xsl:variable>

        <xsl:variable name="vlevel">
            <xsl:variable name="levelListing">
            <xsl:for-each select="distinct-values($tablepage//span[@class='level'])">
                <xsl:if test=". = 1"><l>1</l></xsl:if>
                <xsl:if test=". = 2"><l>2</l></xsl:if>
                <xsl:if test=". = 3"><l>3</l></xsl:if>
                <xsl:if test=". = 4"><l>1</l><l>2</l></xsl:if>
                <xsl:if test=". = 5"><l>2</l><l>3</l></xsl:if>
                <xsl:if test=". = 6"><l>1</l><l>2</l><l>3</l></xsl:if>
            </xsl:for-each>
        </xsl:variable>
            
        <xsl:for-each select="$levelListing">
             <xsl:sort select="l"/>
            <xsl:value-of select="string-join(/*,', ')"/>
        </xsl:for-each>
        </xsl:variable>

        <xsl:message select="$vlevel"></xsl:message>



        <html>
            <head>
                <script src="lang.js"><xsl:text> </xsl:text></script>
                <xsl:text disable-output-escaping='yes'>&lt;link rel="stylesheet" href="levelparser.css"&gt;
                </xsl:text>
                <title>Level Matrix Document Volume: <xsl:value-of select="$docMETADATA//fn:map/fn:string[@key='title']"/></title>
            </head>
            <body>
           <div class="main">      
        <table class="volumelevel">
            <caption>Level Matrix Document Volume: <xsl:value-of select="$docMETADATA//fn:map/fn:string[@key='title']"/></caption>
                    
            <tr><td class="vname" colspan="2"><xsl:value-of select="$docMETADATA//fn:map/fn:string[@key='title']"/></td></tr>
            <tr><td class="url" colspan="2"><a href="{$vurl}"><xsl:value-of select="$vurl"/></a></td></tr>
            <tr><td class="description" colspan="2"><xsl:value-of select="$docMETADATA//fn:map/fn:string[@key='description']"/></td></tr>
            <tr><td class="time" colspan="2"><xsl:value-of select="$docMETADATA//fn:map/fn:string[@key='notBefore']"/> - <xsl:value-of select="$docMETADATA//fn:map/fn:string[@key='notAfter']"/></td></tr>
            <tr><td class="guidelines" colspan="2"><xsl:value-of select="$docMETADATA//fn:map/fn:string[@key='transcription-guidelines']"/></td></tr>
            <xsl:variable name="vtanalyse">
            <tr><td><p class="sumchar" colspan="2"><xsl:value-of select="sum($tablepage//td[@class='sumchar'])"/></p>
                    <ul>
                        <li class="ssl1"><xsl:value-of select="sum($tablepage//td[@class='sl1'])"/></li>
                        <li class="ssl2"><xsl:value-of select="sum($tablepage//td[@class='sl2'])"/></li>
                        <li class="ssl3"><xsl:value-of select="sum($tablepage//td[@class='sl3'])"/></li>
                    </ul>
            </td>
            
            <td  class="leveldesc">
                <button type="button" class="bilanguage" onclick="changeLanguage()" data-en="Deutsch" data-de="English"><xsl:text> </xsl:text></button>
                <p class="bilanguage"><xsl:attribute name="data-de">Die Transkription des Korpus entspricht dem Level <xsl:value-of select="$vlevel"/>.</xsl:attribute><xsl:attribute name="data-en">The Transcription of volume corresponds to level <xsl:value-of select="$vlevel"/>.</xsl:attribute></p>
                <ul><li><a href="https://ocr-d.de/en/gt-guidelines/trans/trGrundsaetze.html"><span class="bilanguage" data-de="Allgemeines zu den Transkriptionslevel" data-en="General explanation of the ground truth levels"/></a></li>
                    <li><a href="https://ocr-d.de/en/gt-guidelines/trans/tr_level_1_4.html"><span class="bilanguage"><xsl:attribute name="data-de">Transkribieren im Level <xsl:value-of select="$vlevel"/></xsl:attribute><xsl:attribute name="data-en">Transcribe in Level <xsl:value-of select="$vlevel"/></xsl:attribute></span></a></li></ul>
            </td>
            </tr>
            </xsl:variable>
            
            <xsl:variable name="vsanalyse">
                <tr><td class="sumchar" colspan="2"><p class="sumchar" colspan="2"><xsl:value-of select="sum($tablepage//td[@class='sumchar'])"/></p>
                <ul>
                    <li class="ssl1"><xsl:value-of select="sum($tablepage//td[@class='sl1'])"/></li>
                    <li class="ssl2"><xsl:value-of select="sum($tablepage//td[@class='sl2'])"/></li>
                    <li class="ssl3"><xsl:value-of select="sum($tablepage//td[@class='sl3'])"/></li>
                </ul>
                </td>
                
                <td  class="leveldesc">
                    <button type="button" class="bilanguage" onclick="changeLanguage()" data-en="Deutsch" data-de="English"><xsl:text> </xsl:text></button>
                    <p class="bilanguage"><xsl:attribute name="data-de">Die Transkription des Korpus entspricht dem Level <xsl:value-of select="$vlevel"/>.</xsl:attribute><xsl:attribute name="data-en">The Transcription of volume corresponds to level <xsl:value-of select="$vlevel"/>.</xsl:attribute></p>
                    <ul><li><a href="https://ocr-d.de/en/gt-guidelines/trans/trGrundsaetze.html"><span class="bilanguage" data-de="Allgemeines zu den Transkriptionslevel" data-en="General explanation of the ground truth levels"/></a></li>
                        <li><a href="https://ocr-d.de/en/gt-guidelines/trans/tr_level_1_4.html"><span class="bilanguage"><xsl:attribute name="data-de">Transkribieren im Level <xsl:value-of select="$vlevel"/></xsl:attribute><xsl:attribute name="data-en">Transcribe in Level <xsl:value-of select="$vlevel"/></xsl:attribute></span></a></li></ul>
                </td>
                </tr>
            </xsl:variable>
            
            
            <xsl:if test="$docMETADATA//fn:map/fn:string[@key/contains(.,'gtTyp')]/text() = 'data_structure'">
                <xsl:apply-imports/><!-- structure analyse with LevelGTStructure.xsl -->
            </xsl:if>
            <xsl:if test="$docMETADATA//fn:map/fn:string[@key/contains(.,'gtTyp')]/text() = 'data_structure_and_text'"><xsl:copy-of select="$vtanalyse"/></xsl:if>
            <xsl:if test="$docMETADATA//fn:map/fn:string[@key/contains(.,'gtTyp')]/text() = 'data_structure' or $docMETADATA//fn:map/fn:string[@key/contains(.,'gtTyp')]/text()='data_structure_and_text'"><xsl:apply-imports/></xsl:if>
            <xsl:if test="$docMETADATA//fn:map/fn:string[@key/contains(.,'gtTyp')]/text() = 'data_line'"><xsl:copy-of select="$vtanalyse"/></xsl:if>
            </table>

                
               
               <xsl:if test="$docMETADATA//fn:map/fn:string[@key/contains(.,'gtTyp')]/text() = 'data_structure_and_text'"><xsl:copy-of select="$tablepage"/></xsl:if>
               <xsl:if test="$docMETADATA//fn:map/fn:string[@key/contains(.,'gtTyp')]/text() = 'data_line'"><xsl:copy-of select="$tablepage"/></xsl:if>
                
           </div>
                
            </body>
        </html>
        </xsl:template>
    </xsl:stylesheet>