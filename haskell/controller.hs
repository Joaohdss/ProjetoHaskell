import ParserJson
import Tipos

-- Checar Ano
checarPorAno a transations = a == ((year . datas) transations)

-- Filtrar transações por ano.
filterPorAno year = do
    transations <- getTransations
    return (filter (checarPorAno year) transations)

-- Checar Mes
checarPorMes m  transations = m == ((month . datas) transations)

-- Filtrar transações por ano e mês.
filterPorAnoMes year month = do
    filterPorAno <- filterPorAno year
    return (filter (checarPorMes month) filterPorAno)


-- Verificando se a 'Transacao' é uma receita ou despesa
-- não pode ser do tipo 'APLICACAO' nem 'VALOR_APLICACAO'

isReceitaOuDespesa t = not (elem "APLICACAO" (tipos t)  || elem "VALOR_APLICACAO" (tipos t))

-- Verificando se é uma receita

isReceita t = (isReceitaOuDespesa t) && (valor t) >= 0

-- Verificando se é uma despesa
isDespesa t = (isReceitaOuDespesa t) && (valor t) < 0

-- Removendo a transação SALDO_CORRENTE


getReceitas ano mes =  do
    transations <- (filterPorAnoMes ano mes)
    return (drop 1 (filter isReceita transations))


getDespesas ano mes =  do
    transations <- (filterPorAnoMes ano mes)
    return (drop 1 (filter isDespesa transations))

-- Calcular o valor das receitas (créditos) em um determinado mês e ano.

calculaCredito ano mes = do
    transations <- getReceitas ano mes
    return ((sum.(map valor)) transations)

calculaDebito ano mes = do
    transations <- getDespesas ano mes
    return ((sum.(map valor)) transations)

-- Calcular a sobra (receitas - despesas) de determinado mês e ano
calculaSobra ano mes = do
    transations <- filterPorAnoMes ano mes
    credito <- (calculaCredito ano mes)
    debito <- (calculaDebito ano mes)
    return (credito - debito)

-- Calcular o saldo final em um determinado ano e mês
calculaSaldoFinalAnoMes ano mes = do
    transations <- (filterPorAnoMes ano mes)
    saldo <- (calculaSobra ano mes)
    return (auxcalculaSaldoMes transations saldo)
auxcalculaSaldoMes [] _ = 0
auxcalculaSaldoMes transations saldo = saldo + (valor (transations !! 0))

-- Calcular o saldo máximo atingido em determinado ano e mês
getSaldoMax ano mes = do
    transations <- filterPorAnoMes ano mes
    return (auxSaldoMax transations)

-- Calcular o saldo mínimo atingido em determinado ano e mês
getSaldoMin ano mes = do
    transations <- filterPorAnoMes ano mes
    return (auxSaldoMin transations)

listSaldo [x] = []
listSaldo (x:y:xs) = [(valor x) + (valor y)] ++ (listSaldo (y:xs))

auxSaldoMin [] = 0
auxSaldoMin transations = ((valor (transations !! 0)) + ( minimum (listSaldo transations)))

auxSaldoMax []  = 0
auxSaldoMax transations = ((valor (transations !! 0)) + ( maximum (listSaldo transations)))

-- Calcular a média das receitas em determinado ano
getMediaCreditoAno ano = (auxMediaCreditoAno ano)

auxMediaCreditoAno ano = do
   total <- sequence (map(calculaCredito ano) [1..12])
   return ((sum total) / meses)
   where 
        meses = 12
-- Calcular a média das despesas em determinado ano
getMediaDebitoAno ano = (auxMediaDebitoAno ano)

auxMediaDebitoAno ano = do
   total <- sequence (map(calculaDebito ano) [1..12])
   return ((sum total) / meses)
   where 
        meses = 12

