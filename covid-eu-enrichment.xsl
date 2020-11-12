<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <xsl:output method="xml" indent="yes" doctype-system="covid.dtd"/>

    <xsl:variable name="countriesCAT"
        select="distinct-values(/covid-eu/country_list/continent/country/@name)"/>
    <xsl:variable name="countriesGID" select="distinct-values(/covid-eu/country_list/continent/country/@xml:id)"/>
    <xsl:variable name="countriesTC" select="distinct-values(/covid-eu/country_list/continent/country/@ctc)"/>

    <xsl:variable name="mondial"
        select="doc('mondial.xml')/mondial/country[@car_code = $countriesTC or 
                                                   @car_code = $countriesGID or 
                                                   ./name/text()= $countriesCAT or ./localname/text() = $countriesCAT]"/>
  
    <xsl:template match="/">
        <covid-eu>
            <!-- xsl:attribute name="mondial" select="count($mondial)"/-->
            <country_list>
                <xsl:apply-templates select="/covid-eu/country_list/continent"/>
            </country_list>
            <xsl:copy-of select="/covid-eu/record_list" />
        </covid-eu>
    </xsl:template>

    <xsl:template match="continent">
        <continent name="{@name}">
            <xsl:apply-templates select="*" />
        </continent>
    </xsl:template>

    <xsl:template name="enrich">
        <xsl:param name="country"/>
        <xsl:param name="mondial"/>
        <country>
            <xsl:copy-of select="@*"/>
            <xsl:choose>
                <xsl:when test="count($mondial) eq 1">
                    <xsl:attribute name="area" select="$mondial/@area" />
                    <xsl:attribute name="car_code" select="$mondial/@car_code"/>
                </xsl:when>
                <xsl:when test="count($mondial) gt 1"><xsl:attribute name="area" select="concat(count($mondial),'*--------------')" /></xsl:when>
                <xsl:otherwise><xsl:attribute name="area">Unkown</xsl:attribute></xsl:otherwise>
            </xsl:choose>
        </country>        
    </xsl:template>

    <xsl:template match="country">
        <xsl:variable name="cnt" select="$mondial[@car_code eq current()/@xml:id or @car_code eq current()/@country-territory-code 
            or  ./name/text()= current()/@name or ./localname/text() = current()/@name]"/>
        <xsl:call-template name="enrich">
            <xsl:with-param name="country" select="."/>
            <xsl:with-param name="mondial" select="$cnt"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:variable name="correctifs">
        <liste-correctifs>
            <correctif covid="MS" mondial="MNTS"/>
            <correctif covid="BQ" mondial="NLB"/>
            <correctif covid="BN" mondial="BRU"/>
            <correctif covid="RO" mondial="RO"/>
            <correctif covid="ES" mondial="E"/>
            <correctif covid="SD" mondial="SUD"/>
            <correctif covid="SY" mondial="SYR"/>
            <correctif covid="CL" mondial="RCH"/>
            <correctif covid="ET" mondial="ETH"/>
            <correctif covid="LB" mondial="RL"/>
            <correctif covid="CW" mondial="CUR"/>
            <correctif covid="CD" mondial="CGO"/> <!-- ou RCB ? -->
            <correctif covid="FK" mondial="FALK"/>
            <correctif covid="GW" mondial="GUB"/>
            <correctif covid="VA" mondial="V"/>
            <correctif covid="TC" mondial="TUCA"/>
            <correctif covid="TZ" mondial="EAT"/>
            <correctif covid="US" mondial="USA"/>
            <correctif covid="VI" mondial="VIRG"/>
        </liste-correctifs>
    </xsl:variable>
    
    <xsl:template match="country[@xml:id = $correctifs/liste-correctifs/correctif/@covid]">
        <xsl:variable name="cnt" select="$correctifs/liste-correctifs/correctif[@covid eq current()/@xml:id]/@mondial"/>
        <xsl:call-template name="enrich">
            <xsl:with-param name="country" select="."/>
            <xsl:with-param name="mondial" select="doc('mondial.xml')/mondial/country[@car_code eq $cnt]"/>
        </xsl:call-template>  
    </xsl:template>   
    
</xsl:transform>
