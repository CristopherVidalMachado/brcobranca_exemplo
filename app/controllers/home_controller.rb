class HomeController < ApplicationController
  layout 'brlayout'

  #TODO passar esses caras para Brcobranca::Boleto::Base
  FORMATOS_SUPORTADOS={
    :pdf => 'application/pdf',
    :jpg => 'image/jpg',
    :tif => 'image/tiff',
    :png => 'image/png'
  }

  def gerar_boleto
    banco=params[:banco].to_sym

    @boleto = case banco
              when :msbank
                Brcobranca::Boleto::Msbank.new
              end

    @boleto.cedente = "MSBANK"
    @boleto.documento_cedente = "19307785000178"
    @boleto.avalista = ""
    @boleto.avalista_documento = ""
    @boleto.valor = 100.25
    @boleto.agencia = "0001"
    @boleto.conta_corrente = "19307785"
    @boleto.variacao = "19"
    @boleto.sacado = "Rafael Augusto Machado Escobar"
    @boleto.sacado_documento = "05260024930"
    @boleto.documento_numero = "564865"

    case banco
    when :msbank
      # ITAU
      # O que diferencia um tipo de boleto de outro, dentro do itáu é o tipo de carteira utilizado.
      @boleto.convenio = "00000"


    end

    @boleto.nosso_numero = "564865"
    @boleto.data_vencimento = "2018-07-27".to_date
    @boleto.instrucao1 = "Pagável na rede bancária até a data de vencimento."
    @boleto.instrucao2 = "Juros de mora de 2.0% mensal(R$ 0,09 ao dia)"
    @boleto.instrucao3 = "DESCONTO DE R$ 29,50 APÓS 05/11/2006 ATÉ 15/11/2006"
    @boleto.instrucao4 = "NÃO RECEBER APÓS 15/11/2006"
    @boleto.instrucao5 = "Após vencimento pagável somente nas agências do Banco do Brasil"
    @boleto.instrucao6 = "ACRESCER R$ 4,00 REFERENTE AO BOLETO BANCÁRIO"
    @boleto.sacado_endereco = "Av. Felipe Wandscher. 2310, Vila Yolanda"
    @boleto.cedente_endereco = "Av. Felipe Wandscher. 2310, Vila Yolanda"

    formato=params[:boleto][:formato].to_sym
    headers['Content-Type']=FORMATOS_SUPORTADOS[formato]
    send_data @boleto.to(formato), :filename => "boleto_#{banco}.#{formato}"
  end

  def index
    @formatos=FORMATOS_SUPORTADOS.keys.map { |v| v.to_s }.sort.map { |v| [v, v] }.sort
  end

  def boleto_hash
    @boleto = Brcobranca::Boleto::BancoBrasil.new :cedente => "Kivanio Barbosa",
      :documento_cedente => "12345678912",
      :sacado => "Claudio Pozzebom",
      :sacado_documento => "12345678900",
      :valor => 135.00,
      :agencia => "4042",
      :conta_corrente => "61900",
      :convenio => "1238798",
      :nosso_numero => "7777700168",
      :data_vencimento => "2008-02-01".to_date,
      :data_documento => "2008-02-01".to_date,
      :instrucao1 => "Pagável na rede bancária até a data de vencimento.",
      :instrucao2 => "Juros de mora de 2.0% mensal(R$ 0,09 ao dia)",
      :instrucao3 => "DESCONTO DE R$ 29,50 APÓS 05/11/2006 ATÉ 15/11/2006",
      :instrucao4 => "NÃO RECEBER APÓS 15/11/2006",
      :instrucao5 => "Após vencimento pagável somente nas agências do Banco do Brasil",
      :instrucao6 => "ACRESCER R$ 4,00 REFERENTE AO BOLETO BANCÁRIO",
      :sacado_endereco => "Av. Rubéns de Mendonça, 157 - 78008-000 - Cuiabá/MT"

    send_data @boleto.to_pdf, :filename => "boleto_hash.pdf"
  end

  def multi_boleto
    boleto_dados = { :cedente => "Kivanio Barbosa",
      :documento_cedente => "12345678912",
      :sacado => "Claudio Pozzebom",
      :sacado_documento => "12345678900",
      :valor => 135.00,
      :agencia => "4042",
      :conta_corrente => "61900",
      :convenio => "1238798",
      :nosso_numero => "7777700168",
      :data_vencimento => "2008-02-01".to_date,
      :data_documento => "2008-02-01".to_date,
      :instrucao1 => "Pagável na rede bancária até a data de vencimento.",
      :instrucao2 => "Juros de mora de 2.0% mensal(R$ 0,09 ao dia)",
      :instrucao3 => "DESCONTO DE R$ 29,50 APÓS 05/11/2006 ATÉ 15/11/2006",
      :instrucao4 => "NÃO RECEBER APÓS 15/11/2006",
      :instrucao5 => "Após vencimento pagável somente nas agências do Banco do Brasil",
      :instrucao6 => "ACRESCER R$ 4,00 REFERENTE AO BOLETO BANCÁRIO",
      :sacado_endereco => "Av. Rubéns de Mendonça, 157 - 78008-000 - Cuiabá/MT" }

    @boletos = []
    @boleto = Brcobranca::Boleto::BancoBrasil.new(boleto_dados)
    @boleto2 = Brcobranca::Boleto::Bradesco.new(boleto_dados)
    @boletos << @boleto
    @boletos << @boleto2

    send_data Brcobranca::Boleto::Base.lote(@boletos), :filename => "multi_boleto.pdf"
  end
end
