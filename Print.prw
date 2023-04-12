#INCLUDE 'Totvs.ch'
#INCLUDE 'Report.ch'
#INCLUDE 'Topconn.ch'

/*/{Protheus.doc} User Function Print
    Função responsável por criar o relatório
    @type  Function
    @author Vinicius Silva
    @since 11/04/2023
/*/
User Function Print()
    Local oReport := GeraReport() 
	
 	oReport:PrintDialog()
Return 

Static Function GeraReport()
	Local cAlias	:= GetNextAlias()
	
	Local oReport	:= TReport():New('Print', 'Relatório de Pedidos de Venda',,{|oReport| Imprime(oReport, cAlias)}, 'Esse relatório imprimirá o Pedido de Venda Selecionado',.F.,,,, .T., .T.)	
	
	Local oSection	:= TRSection():New(oReport, "Cabeçalho do Pedido",,,.F.,.T.)	

	Local oSection2	:= TRSection():New(oSection, "Itens do Pedido",,,.F.,.T.)

	Local oBreak 		
	
    //! SEÇÃO 1 DO RELATÓRIO
	TRCell():New(oSection, 'C6_NUM', 'SC6', 'Numero do Pedido',, 8,,, 'LEFT', .T., 'LEFT',,, .T.,,, .T.)
	TRCell():New(oSection, 'A1_NOME', 'SA1', 'Nome do Cliente',, 30,,, 'LEFT', .T., 'LEFT',,, .T.,,, .T.)
	TRCell():New(oSection, 'C5_EMISSAO', 'SC5', 'Data de Emissao',, 30,,, 'CENTER', .T., 'CENTER',,, .T.,,, .T.)
	TRCell():New(oSection, 'E4_DESCRI', 'SE4', 'Descrição',, 20,,, 'CENTER', .T., 'CENTER',,, .T.,,, .T.)
	
    //! SEÇÃO 2 DO RELATÓRIO
	TRCell():New(oSection2, 'C6_ITEM', 'SC6', 'Nº do Item',, 8,,, 'LEFT', .T., 'LEFT',,, .T.,,, .T.)
	TRCell():New(oSection2, 'C6_PRODUTO', 'SC6', 'Código do Produto',, 30,,, 'LEFT', .T., 'LEFT',,, .T.,,, .T.)
	TRCell():New(oSection2, 'C6_DESCRI', 'SC6', 'Descrição do Produto',, 30,,, 'CENTER', .T., 'CENTER',,, .T.,,, .T.)
	TRCell():New(oSection2, 'C6_QTDVEN', 'SC6', 'Quant. Vendida',, 20,,, 'CENTER', .T., 'CENTER',,, .T.,,, .T.)
	TRCell():New(oSection2, 'C6_PRCVEN', 'SC6', 'Valor Unitario',, 20,,, 'CENTER', .T., 'CENTER',,, .T.,,, .T.)
	TRCell():New(oSection2, 'C6_VALOR', 'SC6', 'Valor Total',, 20,,, 'CENTER', .T., 'CENTER',,, .T.,,, .T.)

    //! Colocar o totalizador
	oBreak := TrBreak():New(oSection, oSection:Cell('C6_NUM'), '', .T.,, .T.)
    TRFunction():New(oSection2:Cell('Valor Total'),'VALTOT','SUM',oBreak,'Valor Total',,,.F.,.F.,.F.)
	
Return oReport

Static Function Imprime(oReport, cAlias)
	Local oSection  := oReport:Section(1)
    Local oSection2 := oSection:Section(1)
	Local nTotReg   := 0
	Local cQuery    := GeraQuery()	   

	DBUseArea(.T., 'TOPCONN', TcGenQry(,, cQuery), cAlias, .T., .T.)	

	Count TO nTotReg 

	oReport:SetMeter(nTotReg)
	oReport:StartPage()
	oSection:Init()  
	oSection2:Init()  

    //! Seção 1
    (cAlias)->(DBGoTop())
    oSection:Cell('Numero do Pedido'):SetValue((cAlias)->C6_NUM)
    oSection:Cell('Nome do Cliente'):SetValue((cAlias)->A1_NOME)
    oSection:Cell('Data de Emissao'):SetValue((cAlias)->C5_EMISSAO)
    oSection:Cell('E4_DESCRI'):SetValue((cAlias)->E4_DESCRI)
	oSection:PrintLine()

	while !(cAlias)->(EoF())
		if oReport:Cancel() 
			Exit
		endif

        //! Seção 2
		oSection2:Cell('Nº do Item'):SetValue((cAlias)->C6_ITEM)
		oSection2:Cell('Codigo do Produto'):SetValue((cAlias)->C6_PRODUTO)
		oSection2:Cell('Descricao do Produto'):SetValue((cAlias)->C6_DESCRI)
		oSection2:Cell('Quant. Vendida'):SetValue((cAlias)->C6_QTDVEN)
		oSection2:Cell('Valor Unitario'):SetValue((cAlias)->C6_PRCVEN)
        oSection2:Cell('Valor Total'):SetValue((cAlias)->C6_VALOR)
      
		oSection2:PrintLine()

		(cAlias)->(DBSkip())
	enddo

	oReport:ThinLine()
	oReport:IncMeter()

	(cAlias)->(DBCloseArea())
	
	oSection:Finish()
	oSection2:Finish()
	
	oReport:EndPage()
Return  

Static Function GeraQuery()
	Local cQuery := ''

	cQuery += "SELECT C6_NUM, A1_NOME, C5_EMISSAO, E4_DESCRI, C6_ITEM, C6_PRODUTO, C6_DESCRI, C6_QTDVEN, C6_PRCVEN, C6_VALOR" + CRLF
	cQuery += "FROM " + RetSqlName('SC5') + " SC5" + CRLF
    cQuery += "INNER JOIN " + RetSqlName('SC6') + " SC6 ON C6_NUM = C5_NUM AND SC6.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "INNER JOIN " + RetSqlName('SA1') + " SA1 ON C5_CLIENTE = A1_COD AND SA1.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "INNER JOIN " + RetSqlName('SE4') + " SE4 ON C5_CONDPAG = E4_CODIGO AND SE4.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE SC5.D_E_L_E_T_= ' '" + CRLF
	cQuery += "AND" + CRLF
	cQuery += "C5_NUM = '" + SC5->C5_NUM + "'" + CRLF 
    
Return cQuery
