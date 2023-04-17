#INCLUDE 'Totvs.ch'
#INCLUDE 'Topconn.ch'
#INCLUDE 'FwPrintSetup.ch'
#INCLUDE 'RptDef.ch'

#DEFINE PRETO    RGB(0,0,0)

#DEFINE MAX_LINE 770

/*/{Protheus.doc} User Function Printer
    Imprimir os dados do fornecedor selecionado
    @type  Function
    @author Vinicius
    @since 13/04/2023
    /*/
User Function Printer()
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

    cQuery += 'SELECT A2_COD, A2_NOME, A2_BAIRRO, A2_EST' + CRLF
	cQuery += 'FROM ' + RetSqlName('SA2') + ' SA2' + CRLF
	cQuery += "WHERE D_E_L_E_T_= ' ' AND A2_COD = '" + SA2->A2_COD + "'" 

    TCQUERY cQuery ALIAS (cAlias) NEW 

    (cAlias)->(DbGoTop())

    if (cAlias)->(EOF()) 
        cAlias := ""
    end

    RestArea(aArea)
Return cAlias 

Static Function MontaRel(cAlias)
    Local cPath    := "C:\Users\TOTVS\Desktop\listas\"
    Local cArquivo := "L11E02.pdf" //*Nome do arquivo que será gerado

    Private nLinha  := 105
    Private oPrint
    Private oFont10 := TFont():New("Arial",/*C*/, 10,/*C*/, .F.,/*C*/,/*C*/,/*C*/,/*C*/, .F., .F.) 
    Private oFont12 := TFont():New("Arial",/*C*/, 12,/*C*/, .T.,/*C*/,/*C*/,/*C*/,/*C*/, .F., .F.) 
    Private oFont14 := TFont():New("Arial",/*C*/, 14,/*C*/, .T.,/*C*/,/*C*/,/*C*/,/*C*/, .F., .F.) 
    Private oFont16 := TFont():New("Arial",/*C*/, 16,/*C*/, .T.,/*C*/,/*C*/,/*C*/,/*C*/, .T., .F.) 

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

    oPrint:Say(nLinha, 20,  "CÓDIGO"  , oFont12, /*Largura*/, PRETO)
    oPrint:Say(nLinha, 100, "NOME"    , oFont12, /*Largura*/, PRETO)
    oPrint:Say(nLinha, 200, "BAIRRO", oFont12, /*Largura*/, PRETO)
    oPrint:Say(nLinha, 320, "ESTADO"  , oFont12, /*Largura*/, PRETO)

    nLinha += 5
    oPrint:Line(nLinha, 15, nLinha, 580, /*COR*/, "-6")

    nLinha += 20
Return 

Static Function ImpDados(cAlias)
    Local cString := ""

    DbSelectArea(cAlias)

    cString := AllTrim((cAlias)->(A2_COD))
    VeriQuebLn(cString, 10, 20)

    cString := AllTrim((cAlias)->(A2_NOME))
    VeriQuebLn(cString, 17, 100)

    cString := AllTrim((cAlias)->(A2_BAIRRO))
    VeriQuebLn(cString, 17, 200)

    cString := AllTrim((cAlias)->(A2_EST))
    oPrint:Say(nLinha, 320, cString, oFont10,,)
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



