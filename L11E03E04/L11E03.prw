#INCLUDE 'Totvs.ch'
#INCLUDE 'Topconn.ch'
#INCLUDE 'FwPrintSetup.ch'
#INCLUDE 'RptDef.ch'

#DEFINE PRETO    RGB(0,0,0)


/*/{Protheus.doc} User Function L11E03
    Imprimir os dados do pedido de compra selecionado
    @type  Function
    @author Vinicius
    @since 13/04/2023
    /*/
User Function L11E03()
    Local cAlias := GeraCons()

    if !Empty(cAlias) 
        Processa({|| MontaRel(cAlias)}, "Aguarde...", "Imprimindo Relatório...", .F.) 
    else 
        FwAlertError("Nenhum registro encontrado", "Atenção!")
    endif
Return 

Static Function GeraCons()
    Local aArea  := GetArea()
    Local cAlias := GetNextAlias()
    Local cQuery := ""

    cQuery += 'SELECT C7_NUM, C7_EMISSAO, C7_FORNECE, C7_LOJA, C7_COND, C7_PRODUTO, C7_DESCRI, C7_QUANT, C7_PRECO, C7_TOTAL' + CRLF
	cQuery += 'FROM ' + RetSqlName('SC7') + ' SC7' + CRLF
	cQuery += "WHERE D_E_L_E_T_= ' ' AND C7_NUM = '" + SC7->C7_NUM + "'" 

    TCQUERY cQuery ALIAS (cAlias) NEW 

    (cAlias)->(DbGoTop())

    if (cAlias)->(EOF()) 
        cAlias := ""
    end

    RestArea(aArea)
Return cAlias 

Static Function MontaRel(cAlias)
    Local cPath    := "C:\Users\TOTVS\Desktop\listas\"
    Local cArquivo := "L11E03E04.pdf" //*Nome do arquivo que será gerado

    Private nLinha     := 105
    Private nLinhaSec2 := 200 //* Linha para fazer o cabeçalho da segunda seção
    Private oPrint
    Private oFont10  := TFont():New("Arial",/*C*/, 10,/*C*/, .F.,/*C*/,/*C*/,/*C*/,/*C*/, .F., .F.) 
    Private oFont10S := TFont():New("Arial",/*C*/, 10,/*C*/, .F.,/*C*/,/*C*/,/*C*/,/*C*/, .T., .F.) 
    Private oFont12  := TFont():New("Arial",/*C*/, 12,/*C*/, .T.,/*C*/,/*C*/,/*C*/,/*C*/, .F., .F.) 
    Private oFont14  := TFont():New("Arial",/*C*/, 14,/*C*/, .T.,/*C*/,/*C*/,/*C*/,/*C*/, .F., .F.) 
    Private oFont16  := TFont():New("Arial",/*C*/, 16,/*C*/, .T.,/*C*/,/*C*/,/*C*/,/*C*/, .T., .F.) 

    oPrint := FwMsPrinter():New(cArquivo, IMP_PDF, .F., "", .T.,/*TReport*/, @oPrint, "", /*LServer*/,/*C*/,/*RAW*/,.T.) 
    
    oPrint:cPathPDF := cPath
    
    oPrint:SetPortrait()
    
    oPrint:SetPaperSize(9)

    oPrint:StartPage()

    Cabecalho()
    ImpDados(cAlias)

    oPrint:EndPage()

    oPrint:Preview()

Return 

Static Function Cabecalho()
    oPrint:Box(15, 15, 85, 580, "-8") 
    oPrint:Line(85, 15, 15, 580, PRETO, "-6") 
    
    oPrint:Say(35, 20, "Empresa / Filial: " + AllTrim(SM0->M0_NOME) + " / " + AllTrim(SM0->M0_FILIAL), oFont14,, PRETO)
    oPrint:Say(70, 220, "Fornecedor Selecionado ", oFont16,, PRETO)

    oPrint:Say(nLinha, 20,  "Nº PEDIDO"  , oFont12, /*Largura*/, PRETO)
    oPrint:Say(nLinha, 100, "DATA DE EMISSAO"    , oFont12, /*Largura*/, PRETO)
    oPrint:Say(nLinha, 200, "COD. FORNECEDOR", oFont12, /*Largura*/, PRETO)
    oPrint:Say(nLinha, 320, "LOJA FORNECEDOR"  , oFont12, /*Largura*/, PRETO)
    oPrint:Say(nLinha, 450, "COND. PAGAMENTO"  , oFont12, /*Largura*/, PRETO)

    nLinha += 5
    oPrint:Line(nLinha, 15, nLinha, 580, /*COR*/, "-6")

    nLinha += 20

    //! Parte responsável pela 2ª seção do relatório
    oPrint:Say(nLinhaSec2, 20,  "COD. PRODUTO"     , oFont12, /*Largura*/, PRETO)
    oPrint:Say(nLinhaSec2, 100, "DESC. PRODUTO"    , oFont12, /*Largura*/, PRETO)
    oPrint:Say(nLinhaSec2, 200, "QUANT. VENDIDA"   , oFont12, /*Largura*/, PRETO)
    oPrint:Say(nLinhaSec2, 320, "VALOR UNITARIO"   , oFont12, /*Largura*/, PRETO)
    oPrint:Say(nLinhaSec2, 450, "VALOR TOTAL"      , oFont12, /*Largura*/, PRETO)

    nLinhaSec2 += 5
    oPrint:Line(nLinhaSec2, 15, nLinhaSec2, 580, /*COR*/, "-6")

    nLinhaSec2 += 20
Return 

Static Function ImpDados(cAlias)
    Local cString      := ""
    Local nTotalizador := 0

    DbSelectArea(cAlias)

    cString := AllTrim((cAlias)->(C7_NUM))
    VeriQuebLn(cString, 10, 20)

    cString := Dtoc(Stod(AllTrim((cAlias)->(C7_EMISSAO))))
    VeriQuebLn(cString, 17, 110)

    cString := AllTrim((cAlias)->(C7_FORNECE))
    VeriQuebLn(cString, 17, 225)

    cString := AllTrim((cAlias)->(C7_LOJA))
    oPrint:Say(nLinha, 360, cString, oFont10,,)

    cString := AllTrim((cAlias)->(C7_COND))
    oPrint:Say(nLinha, 490, cString, oFont10,,)

    //! Loop para mostrar os produtos do pedido de venda selecionado
    (cAlias)->(DbGoTop())
    while (cAlias)->(!EOF())
        cString := AllTrim((cAlias)->(C7_PRODUTO))
        oPrint:Say(nLinhaSec2, 20, cString, oFont10,,)

        cString := AllTrim((cAlias)->(C7_DESCRI))
        VerQueLnS2(cString, 20, 110)

        cString := cValToChar((cAlias)->(C7_QUANT))
        oPrint:Say(nLinhaSec2, 225, cString, oFont10,,)

        cString := cValToChar((cAlias)->(C7_PRECO))
        oPrint:Say(nLinhaSec2, 360, "R$ " + cString, oFont10,,)

        cString := cValToChar((cAlias)->(C7_TOTAL))
        oPrint:Say(nLinhaSec2, 490, "R$ " + cString, oFont10,,)
        nTotalizador += (cAlias)->(C7_TOTAL)

        nLinhaSec2 += 30
        IncProc() 
        (cAlias)->(DbSkip())
    end

    oPrint:Say(nLinhaSec2, 490, "Totalizador: R$ " + cValToChar(nTotalizador), oFont10S,,)
Return 

Static Function VeriQuebLn(cString, nQtdCar, nCol)
    Local cTxtLinha  := ""
    Local lTemQuebra := .F.
    Local nQtdLinhas := MLCount(cString, nQtdCar, /*TAB*/,.F.)
    Local nI         := 0

    if nQtdLinhas > 1
        lTemQuebra := .T.
        for nI := 1 to nQtdLinhas
            cTxtLinha := MemoLine(cString, nQtdCar, nI)
            oPrint:Say(nLinha, nCol, cTxtLinha, oFont10,,) 
            nLinha += 10  
        next
    else
        oPrint:Say(nLinha, nCol, cString, oFont10,,)   
    endif

    if lTemQuebra
        nLinha -= nQtdLinhas * 10
    endif
Return 

Static Function VerQueLnS2(cString, nQtdCar, nCol)
    //! Verifica a quebra de linha da seção 2
    Local cTxtLinha  := ""
    Local lTemQuebra := .F.
    Local nQtdLinhas := MLCount(cString, nQtdCar, /*TAB*/,.F.)
    Local nI         := 0

    if nQtdLinhas > 1
        lTemQuebra := .T.
        for nI := 1 to nQtdLinhas
            cTxtLinha := MemoLine(cString, nQtdCar, nI)
            oPrint:Say(nLinhaSec2, nCol, cTxtLinha, oFont10,,) 
            nLinhaSec2 += 10  
        next
    else
        oPrint:Say(nLinhaSec2, nCol, cString, oFont10,,)   
    endif

    if lTemQuebra
        nLinhaSec2 -= nQtdLinhas * 10
    endif
Return 


