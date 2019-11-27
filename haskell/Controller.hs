import Tipos
import Data.List (groupBy)
import ParserJson

--- Auxiliares
filtro []  _ = []
filtro (x:xs) ys = if elem x ys then (filtro xs ys) ++ [x] else (filtro xs ys)
-- Checar Ano
checarPorAno a transations = a == ((year . datas) transations)
-- Checar Mes
checarPorMes m transations = m == ((month . datas) transations)
-- Checando o dia
checarDia d t = d == ((dayOfMonth . datas) t)
-- Filtrar transações por ano.
filterAno year = do
    transactions <- getTransations
    return (((filter . checarPorAno) year) transactions)

-- Filtrar transações por ano e mês.
filterAnoMes ano mes = do
    anos <- filterAno ano
    return (((filter . checarPorMes) mes) anos)
    
-- Verificando se a 'Transacao' é uma receita ou despesa
-- não pode ser do tipo 'APLICACAO' nem 'VALOR_APLICACAO'
isReceiptOrDebt :: Transacao -> Bool
isReceiptOrDebt t = (filtro (tipos t) [APLICACAO, SALDO_CORRENTE, VALOR_APLICACAO]) == []

getCreditosDebitos ano mes = do
    transations <- (filterAnoMes ano mes)
    return (filter isReceiptOrDebt transations)

-- Verificando se a 'Transacao' é uma receita
ehReceita transations = (valor transations) > 0

-- Verificando se a 'Transacao' é uma despesa

ehDespesa transations = (valor transations) < 0

-- Retorna a lista de débitos
getDebitos ano mes =  do
    transations <- (getCreditosDebitos ano mes)
    return (filter ehDespesa transations)

-- Retorna a lista de créditos
getCreditos ano mes =  do
    transations <- (getCreditosDebitos ano mes)
    return (filter ehReceita transations)

-- Calcular o valor das receitas (créditos) em um determinado mês e ano.
calculaCredito ano mes = do
    transationsCretidos <- getCreditos ano mes
    return ((sum.(map valor)) transationsCretidos)

-- Calcular o valor das despesas (débitos) em um determinado mês e ano.
calculaDebito ano mes = do
    transationsDebitos <- getDebitos ano mes
    return ((sum.(map valor)) transationsDebitos)

-- Calcular a sobra (receitas - despesas) de determinado mês e ano
calculaSobra ano mes = do
    credit <- (calculaCredito ano mes)
    debit <- (calculaDebito ano mes)
    return (credit + debit)

-- Calcular o saldo final em um determinado ano e mês
calculaSaldoFinalAnoMes ano mes = do
    baseBalance <- (initialBalance ano mes)
    remainer <- (calculaSobra ano mes)
    return (baseBalance + remainer)

-- Calcular o saldo máximo atingido em determinado ano e mês
getSaldoMax ano mes = do
    balanco <- (initialBalance ano mes)
    transations <- (getCreditosDebitos ano mes)
    return (auxSaldoMax transations balanco)

auxSaldoMax [] _= 0
auxSaldoMax transactions monthBalance = ( maximum (balances (reverse (monthBalance:(map valor transactions)))))
    
-- Calcular o saldo mínimo atingido em determinado ano e mês
getSaldoMin ano mes= do
    balanco <- (initialBalance ano mes)
    transations <- (getCreditosDebitos ano mes)
    return (auxSaldoMin transations balanco)

auxSaldoMin [] _= 0
auxSaldoMin transations monthBalance = ( minimum (balances (reverse (monthBalance:(map valor transations)))))

--lista com os balanços
balances [x] = [x]
balances (x:xs) = (x + (sum xs):(balances xs))

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


-- Auxiliares FALTA AJEITAR 
firstTransaction y m = do
    transactions <- (filterAnoMes y m)
    return (_firstTransaction transactions)

_firstTransaction [] = []
_firstTransaction xs = [(xs !! 0)]

initialBalance :: Int -> Int -> IO Double
initialBalance y m = do
    transaction <- (firstTransaction y m)
    return (_initialBalance transaction)

_initialBalance :: [Transacao] -> Double
_initialBalance [] = 0
_initialBalance xs = valor (xs !! 0)

-- Retornar o fluxo de caixa de determinado mês/ano. 
-- O fluxo de caixa nada mais é do que uma lista contendo pares (dia,saldoFinalDoDia). 

getFluxo year month = do
    expenses <- (getDebitos year month)
    incomes <- (getCreditos year month)
    return (_getCashFlow (ordenaDecrescente (expenses ++ incomes)))

_getCashFlow transations = map sumDayFlow (groupBy diaIgual transations)

sumDayFlow transations = (((dayOfMonth . datas) (transations !! 0)) , (sum (map valor transations)))


diaIgual tran1 tran2 = result
    where 
        result = ((dayOfMonth . datas) tran1) == ((dayOfMonth . datas) tran2)


-- Ordena uma lista de Transacao por dia
ordenaDecrescente [] = []
ordenaDecrescente (x:xs) = (ordenaDecrescente esq) ++ [x] ++ (ordenaDecrescente dir)
    where 
        esq = filter (menor x) xs
        dir =  filter (maior x) xs

menor p t2 = result
   where
      result = ((dayOfMonth . datas) p) > ((dayOfMonth . datas) t2)

maior p t2 = result
   where
      result = ((dayOfMonth . datas) p) <= ((dayOfMonth . datas) t2)


