#INCLUDE 'Totvs.ch'
#INCLUDE 'Topconn.ch'
#INCLUDE 'FwPrintSetup.ch'
#INCLUDE 'RptDef.ch'

#DEFINE PRETO    RGB(000, 000, 000)
 
/*/{Protheus.doc} User Function Challenge
    Challenge da lista 11
    @type  Function
    @author Vinicius Silva
    @since 15/04/2023
/*/
User Function Challenge()
    Local cAlias := GeraCons()
    if !Empty(cAlias)
        //? Régua de processamento
	    Processa({|| MontaRel(cAlias)}, "Aguarde...", "Imprimindo relatório...", .F.)
    else    
        FwAlertError("Nenhum Registro encontrado!", "Atenção")
    endif
Return

//! Função que gera e executa a consulta no BD.
Static Function GeraCons()
    Local aArea  := GetArea()
    Local cAlias := GetNextAlias()
    Local cQuery := ''
    
    // cQuery += "SELECT C5_NUM, C5_EMISSAO, C5_CONDPAG, C5_ESPECI1, C5_VOLUME1, C5_DESC1, C5_TPFRETE, C6_ITEM, C6_PRODUTO, C6_DESCRI, C6_UM, C6_QTDVEN, C6_PRCVEN, C6_VALOR, C6_IPITRF, C6_ENTREG, A1_NOME, A1_EMAIL, A1_END, A1_MUN, A1_TEL, A1_CGC, A1_IPWEB, A1_CONTATO, A1_BAIRRO, A1_CEP, A1_FAX, A1_IENCONT, E4_DESCRI, A4_NOME" + CRLF
	// cQuery += "FROM " + RetSqlName('SC5') + " SC5" + CRLF
    // cQuery += "INNER JOIN " + RetSqlName('SC6') + " SC6 ON C6_NUM = C5_NUM AND SC6.D_E_L_E_T_ = ' ' " + CRLF
    // cQuery += "INNER JOIN " + RetSqlName('SA4') + " SA4 ON A4_COD = C5_TRANSP AND SA4.D_E_L_E_T_ = ' ' " + CRLF
    // cQuery += "INNER JOIN " + RetSqlName('SA1') + " SA1 ON C5_CLIENTE = A1_COD AND SA1.D_E_L_E_T_ = ' ' " + CRLF
    // cQuery += "INNER JOIN " + RetSqlName('SE4') + " SE4 ON C5_CONDPAG = E4_CODIGO AND SE4.D_E_L_E_T_ = ' ' " + CRLF
	// cQuery += "WHERE SC5.D_E_L_E_T_= ' ' AND C5_NUM = '" + SC5->C5_NUM + "'"

    cQuery += "SELECT C6_NUM, A1_NOME, C5_EMISSAO, C5_FRETE, C5_DESPESA, C5_NUM, E4_DESCRI, C6_ITEM, C6_PRODUTO, C6_DESCRI, C6_UM, C6_QTDVEN, C6_PRCVEN, C6_VALOR, C6_IPITRF, C6_ENTREG, A1_NOME, A1_EMAIL, A1_END, A1_MUN, A1_TEL, A1_CGC, A1_IPWEB, A1_CONTATO, A1_BAIRRO, A1_CEP, A1_FAX, A1_IENCONT" + CRLF
	cQuery += "FROM " + RetSqlName('SC5') + " SC5" + CRLF
    cQuery += "INNER JOIN " + RetSqlName('SC6') + " SC6 ON C6_NUM = C5_NUM AND SC6.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "INNER JOIN " + RetSqlName('SA1') + " SA1 ON C5_CLIENTE = A1_COD AND SA1.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "INNER JOIN " + RetSqlName('SE4') + " SE4 ON C5_CONDPAG = E4_CODIGO AND SE4.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE SC5.D_E_L_E_T_= ' '" + CRLF
	cQuery += "AND" + CRLF
	cQuery += "C5_NUM = '" + SC5->C5_NUM + "'" + CRLF 

    TCQUERY cQuery ALIAS (cAlias) NEW

    (cAlias)->(DbGoTop())
    if (cAlias)->(EOF())
       cAlias := '' 
    endif
    
    RestArea(aArea)
Return cAlias

//! Função que configura o relatório
Static Function MontaRel(cAlias)
    Local cCamPDF    := 'C:\Users\TOTVS\Desktop\listas\'
    Local cArqPDF    := 'Challenge.pdf'

    Private nLinha       := 100
    Private nQuantProd   := 0
    Private nTotalizador := 0
    Private oPrint

    //! Criando padrões de fontes
    Private oFont08  := TFont():New("Arial",, 08,, .F.,,,,, .F., .F.)
    Private oFont10  := TFont():New("Arial",, 10,, .F.,,,,, .F., .F.)
    Private oFont10N := TFont():New("Arial",, 10,, .T.,,,,, .F., .F.)
    Private oFont12  := TFont():New("Arial",, 12,, .F.,,,,, .F., .F.)
    Private oFont12N := TFont():New("Arial",, 12,, .T.,,,,, .F., .F.)
    Private oFont14  := TFont():New("Arial",, 14,, .T.,,,,, .F., .F.)
    Private oFont16  := TFont():New("Arial",, 16,, .T.,,,,, .T., .F.)

    //! Criando e configurando o objeto de impressão
    oPrint := FWMSPrinter():New(cArqPDF, IMP_PDF, .F., "", .T.,, @oPrint, "",,,, .T.)
    oPrint:cPathPDF := cCamPDF
    oPrint:SetPortrait()
    oPrint:setPaperSize(9)
    oPrint:StartPage()
    Cabecalho(cAlias)
    CabItens()
    ImpDados(cAlias)
    TabItens()
    RelRodap(cAlias)
    oPrint:endPage()
    oPrint:Preview()
Return

//! Função que cria o cabeçalho do relatório com o logo
Static Function Cabecalho(cAlias)
    Local cLogo := ("\system\LGRL" + SM0->M0_CODIGO + ".png")

    oPrint:SayBitMap(20, 20, cLogo, 70, 65)

    //? Imprimindo informações da empresa no cabeçalho
    oPrint:Say(20, 400, AllTrim(SM0->M0_ENDENT), oFont14,, PRETO)
    oPrint:Say(30, 405, "AV. BRASIL, 329 CAMPINAS/SP 13098-888" , oFont12,, PRETO)
    oPrint:Say(40, 415, "E-mail: motores@ultramotores.com.br", oFont10N,, PRETO)
    oPrint:Say(50, 430, "Fone: 30276600 FAX: 30276600", oFont10,, PRETO)
    oPrint:Say(60, 395, "CNPJ: 52.113.791/0001-22 IE: 111.010.945.111", oFont10,, PRETO)

    //? Informações iniciais do Pedido de Venda
    oPrint:Line(85, 015, 85, 580, /*Cor*/, '-9')
    oPrint:Say(nLinha, 20, "PEDIDO DE VENDA Nº " + AllTrim((cAlias)->(C5_NUM)),    oFont14,, PRETO)
    oPrint:Say(nLinha, 485, "DATA: " + Dtoc(Stod(AllTrim((cAlias)->(C5_EMISSAO)))),    oFont14,, PRETO)
    oPrint:Line(110, 015, 110, 580, /*Cor*/, '-9')

    //? Informações do cliente - Lado Esquerdo
    nLinha += 25
    oPrint:Say(nLinha, 20, "Cliente: " + AllTrim((cAlias)->(A1_NOME)),    oFont12,, PRETO)
    nLinha += 15
    oPrint:Say(nLinha, 20, "E-mail: " + AllTrim((cAlias)->(A1_EMAIL)),    oFont12,, PRETO)
    nLinha += 15
    oPrint:Say(nLinha, 20, "Endereco: " + AllTrim((cAlias)->(A1_END)),    oFont12,, PRETO)
    nLinha += 15
    oPrint:Say(nLinha, 20, "Cidade: " + AllTrim((cAlias)->(A1_MUN)),    oFont12,, PRETO)
    nLinha += 15
    oPrint:Say(nLinha, 20, "Telefone: " + AllTrim((cAlias)->(A1_TEL)),    oFont12,, PRETO)
    nLinha += 15
    oPrint:Say(nLinha, 20, "CNPJ: " + AllTrim((cAlias)->(A1_CGC)),    oFont12,, PRETO)

    //? Informações do cliente - Lado Direito
    nLinha := 100
    nLinha += 25
    oPrint:Say(nLinha, 320, "Site: www.microsiga.com.br"  /* + AllTrim((cAlias)->(A1_IPWEB))*/,    oFont12,, PRETO)
    nLinha += 15
    oPrint:Say(nLinha, 320, "Contato: " + AllTrim((cAlias)->(A1_CONTATO)),    oFont12,, PRETO)
    nLinha += 15
    oPrint:Say(nLinha, 320, "Bairro: " + AllTrim((cAlias)->(A1_BAIRRO)),    oFont12,, PRETO)
    nLinha += 15
    oPrint:Say(nLinha, 320, "CEP: " + AllTrim((cAlias)->(A1_CEP)),    oFont12,, PRETO)
    nLinha += 15
    oPrint:Say(nLinha, 320, "FAX: " + AllTrim((cAlias)->(A1_FAX)),    oFont12,, PRETO)
    nLinha += 15
    oPrint:Say(nLinha, 320, "I.E: 395.006.741.113" /*+ AllTrim((cAlias)->(A1_IENCONT))*/,    oFont12,, PRETO)

    nLinha += 25
    
Return

//! Função que cria o cabeçalho da tabela de itens do pedido de venda
Static Function CabItens()
    oPrint:Line(215, 20, 215, 580,,"-2")
    oPrint:Say(nLinha, 25,  'Item'                , oFont12N, , PRETO)
    oPrint:Say(nLinha, 55,  'Produto'             , oFont12N, , PRETO)
    oPrint:Say(nLinha, 120, 'Descrição do Produto', oFont12N, , PRETO)
    oPrint:Say(nLinha, 250, 'UM'                  , oFont12N, , PRETO)
    oPrint:Say(nLinha, 280, 'Qtd.'                , oFont12N, , PRETO)
    oPrint:Say(nLinha, 320, 'Prc Unit'            , oFont12N, , PRETO)
    oPrint:Say(nLinha, 400, 'Prc Total'           , oFont12N, , PRETO)
    oPrint:Say(nLinha, 465, 'IPI'                 , oFont12N, , PRETO)
    oPrint:Say(nLinha, 505, 'Data Entrega'        , oFont12N, , PRETO)
    oPrint:Line(230, 20, 230, 580,,"-2")
Return

//! Função que vai imprimir os itens do pedido de venda selecionado
Static Function ImpDados(cAlias)
    DbSelectArea(cAlias)
    (cAlias)->(DbGoTop())

    //? Laço de repetição para trazer todos os itens do pedido de venda selecionado
    while (cAlias)->(!EOF())
        nQuantProd++ //? Para saber quantos itens o pedido de vendas tem
        nLinha += 15

        oPrint:Say(nLinha, 25, AllTrim((cAlias)->(C6_ITEM)), oFont10,, PRETO)
        oPrint:Say(nLinha, 55, AllTrim((cAlias)->(C6_PRODUTO)), oFont10,, PRETO)
        oPrint:Say(nLinha, 120, AllTrim((cAlias)->(C6_DESCRI)), oFont10,, PRETO)
        oPrint:Say(nLinha, 250, AllTrim((cAlias)->(C6_UM)), oFont10,, PRETO)
        oPrint:Say(nLinha, 280, cValToChar((cAlias)->(C6_QTDVEN)), oFont10,, PRETO)
        oPrint:Say(nLinha, 320, cValToChar((cAlias)->(C6_PRCVEN)), oFont10,, PRETO)
        oPrint:Say(nLinha, 400, cValToChar((cAlias)->(C6_VALOR)), oFont10,, PRETO)
        nTotalizador += (cAlias)->(C6_VALOR)
        oPrint:Say(nLinha, 465, cValToChar((cAlias)->(C6_IPITRF)), oFont10,, PRETO)
        oPrint:Say(nLinha, 505, Dtoc(Stod(AllTrim((cAlias)->(C6_ENTREG)))), oFont10,, PRETO)
     
        (cALias)->(DbSkip())
    enddo

    (cAlias)->(DbCloseArea())
Return

//! Função responsável por montar a tabela do totalizador
//! Parâmetro para deixar a tabela dinâmica
Static Function TabTot(nTamBox)
    nTamBox += 20
    //? Monta a Tabela
    oPrint:Line(nTamBox, 318, nTamBox, 463,,"-2") //* Linha horizontal final
    oPrint:Line(215, 318, nTamBox, 318,,"-2") //* Linha vertical inicial
    oPrint:Line(215, 398, nTamBox, 398,,"-2") //* Linha vertical final 
    oPrint:Line(215, 463, nTamBox, 463,,"-2") 

    //? Informações do totalizador
    nTamBox -= 10
    oPrint:Say(nTamBox, 320, "Valor Total", oFont12N,, PRETO)
    oPrint:Say(nTamBox, 400, "R$ " + cValToChar(nTotalizador), oFont10,, PRETO)
Return 

//! Função responsável pela tabela do frete e da despesa
//! Parâmetro para deixar a tabela dinâmica
Static Function TabFre(nTamBox)
     nTamBox += 20
    //? Monta a Tabela
    oPrint:Line(nTamBox, 118, nTamBox, 278,,"-2") //* Linha horizontal final da parte do frete
    oPrint:Line(215, 118, nTamBox + 20, 118,,"-2") //* Linha vertical inicial
    oPrint:Line(255, 278, nTamBox + 20, 278,,"-2") //* Linha vertical final 
    oPrint:Line(nTamBox - 20, 200, nTamBox + 20, 200,,"-2") //* Linha vertical do meio
    oPrint:Line(nTamBox + 20, 118, nTamBox + 20, 278,,"-2") //* Linha horizontal final da parte da despesa
    

    //? Informações do frete
    oPrint:Say(nTamBox - 5, 120, "Valor Frete", oFont12N,, PRETO)
    oPrint:Say(nTamBox - 5, 210, "R$ 0, 00"  , oFont10,, PRETO)

    //? Informações da despesa
    oPrint:Say(nTamBox + 15, 120, "Valor Despesa", oFont12N,, PRETO)
    oPrint:Say(nTamBox + 15, 210, "R$ 0, 00"  , oFont10,, PRETO)
Return 

//! Função que cria uma tabela dinâmica para organizar os itens do pedido de venda 
Static Function TabItens()
    Local nTamBox    := 0

    //? Lógica para deixar a linha inferior e as linhas verticais dinâmicas para qualquer quant. de itens do pedido de vendas
    nLinha  := 240
    nTamBox := nLinha + (nQuantProd * 15)
    oPrint:Line(nTamBox, 20, nTamBox, 580,,"-2") //?Parâmetros p/ linha inferior
    //?Parâmetros p/ linhas verticais
    oPrint:Line(215, 20, nTamBox, 20,,"-2")
    oPrint:Line(215, 53, nTamBox, 53,,"-2")
    oPrint:Line(215, 118, nTamBox, 118,,"-2")
    oPrint:Line(215, 248, nTamBox, 248,,"-2")
    oPrint:Line(215, 248, nTamBox, 248,,"-2")
    oPrint:Line(215, 278, nTamBox, 278,,"-2")
    oPrint:Line(215, 318, nTamBox, 318,,"-2")
    oPrint:Line(215, 398, nTamBox, 398,,"-2")
    oPrint:Line(215, 463, nTamBox, 463,,"-2")
    oPrint:Line(215, 503, nTamBox, 503,,"-2")
    oPrint:Line(215, 580, nTamBox, 580,,"-2")

    TabFre(nTamBox)
    TabTot(nTamBox)
Return 

//! Função para criar o rodapé do relatório
Static Function RelRodap(cAlias)
    oPrint:Line(680, 1, 680, 600,,"-4") //? 1ª Linha horizontal
    oPrint:Line(775, 1, 775, 600,,"-4") //? 2ª Linha horizontal
    oPrint:Line(800, 1, 800, 600,,"-4") //? 3ª Linha horizontal

    //? Informações Gerais
    //* Lado esquerdo
    oPrint:Say(690, 225, "Informações Gerais: ", oFont14,, PRETO)

    oPrint:Say(705, 15, "Forma de Pagamento", oFont12N,, PRETO)
    oPrint:Say(705, 120, ": 001 - A VISTA", oFont12,, PRETO)

    oPrint:Say(720, 15, "Transportadora", oFont12N,, PRETO)
    oPrint:Say(720, 120, ": (000001) Propria", oFont12,, PRETO)

    oPrint:Say(735, 15, "Espécie", oFont12N,, PRETO)
    oPrint:Say(735, 120, ": ESPECIE", oFont12,, PRETO)

    oPrint:Say(750, 15, "Volume", oFont12N,, PRETO)
    oPrint:Say(750, 120, ": 0", oFont12,, PRETO)

    oPrint:Say(750, 15, "Volume", oFont12N,, PRETO)
    oPrint:Say(750, 120, ": 0", oFont12,, PRETO)

    oPrint:Say(765, 15, "Desconto %", oFont12N,, PRETO)
    oPrint:Say(765, 120, ": 0.00 + 0.00 + 0.00 + 0.00", oFont12,, PRETO)

    //*Lado direito
    oPrint:Say(735, 300, "Tipo Frete", oFont12N,, PRETO)
    oPrint:Say(735, 350, ": FOB", oFont12,, PRETO)



    //? Informa a mensagem final
    oPrint:Say(788, 15, "Mensagem: ", oFont12N,, PRETO)
    oPrint:Say(788, 70, "MENSAGEM PARA PEDIDO DO MURIEL" /*+ AllTrim((cAlias)->(A1_CONTATO))*/, oFont12,, PRETO)

    //? Informa a página
    oPrint:Say(820, 520, "Página:       1/1", oFont12N,, PRETO)
Return 


