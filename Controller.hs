module Controller where
import ParserJson
import Tipos
import Data.List (groupBy)

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

-- Retorna receita
getReceitas ano mes =  do
    transations <- (filterPorAnoMes ano mes)
    return (drop 1 (filter isReceita transations))

-- Retorna despesas isExpense
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


-- Calcular a média das sobras em determinado ano
getMediaSobrasAno ano = (auxMediaSobrasAno ano)

auxMediaSobrasAno ano = do
   total <- sequence (map(calculaSaldoFinalAnoMes ano) [1..12])
   return ((sum total) / meses)
   where 
        meses = 12




-- Retornar o fluxo de caixa de determinado mês/ano. 
-- O fluxo de caixa nada mais é do que uma lista contendo pares (dia,saldoFinalDoDia). 

getFluxo year month = do
    expenses <- (getDespesas year month)
    incomes <- (getReceitas year month)
    return (_getCashFlow (ordenaDecrescente (expenses ++ incomes)))

_getCashFlow transations = map sumDayFlow (groupBy diaIgual transations)

sumDayFlow transations = (((dayOfMonth . datas) (transations !! 0)) , (sum (map valor transations)))


diaIgual tran1 tran2 = result
    where 
        result = ((dayOfMonth . datas) tran1) == ((dayOfMonth . datas) tran2)


-- Ordena uma lista de Transacao por dia
ordenaDecrescente [] = []
ordenaDecrescente (x:xs) = (ordenaDecrescente dir) ++ [x] ++ (ordenaDecrescente esq)
    where 
        esq = filter (menor x) xs
        dir =  filter (maior x) xs

menor p t2 = result
   where
      result = ((dayOfMonth . datas) p) > ((dayOfMonth . datas) t2)

maior p t2 = result
   where
      result = ((dayOfMonth . datas) p) <= ((dayOfMonth . datas) t2)


