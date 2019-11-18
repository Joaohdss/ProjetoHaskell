import ParserJson
import Tipos

-- Checar Ano
checarPorAno :: Int -> Transacao -> Bool
checarPorAno a transations = a == ((year . datas) transations)

-- Filtrar transações por ano.
filterPorAno :: Int -> IO [Transacao]
filterPorAno year = do
    transations <- getTransations
    return (filter (checarPorAno year) transations)

-- Checar Mes
checarPorMes :: Int -> Transacao -> Bool
checarPorMes m  transations = m == ((month . datas) transations)

-- Filtrar transações por ano e mês.
filterPorAnoMes :: Int -> Int  -> IO [Transacao]
filterPorAnoMes year month = do
    filterPorAno <- filterPorAno year
    return (filter (checarPorMes month) filterPorAno)


-- Verificando se a 'Transacao' é uma receita ou despesa
-- não pode ser do tipo 'APLICACAO' nem 'VALOR_APLICACAO'
isReceitaOuDespesa :: Transacao -> Bool
isReceitaOuDespesa t = not (elem "APLICACAO" (tipos t)  || elem "VALOR_APLICACAO" (tipos t))

-- Verificando se é uma receita
isReceita :: Transacao -> Bool
isReceita t = (isReceitaOuDespesa t) && (valor t) >= 0

-- Verificando se é uma despesa
isDespesa :: Transacao -> Bool
isDespesa t = (isReceitaOuDespesa t) && (valor t) < 0

-- Removendo a transação SALDO_CORRENTE

getReceitas :: Int -> Int -> IO [Transacao]
getReceitas ano mes =  do
    transations <- (filterPorAnoMes ano mes)
    return (drop 1 (filter isReceita transations))

getDespesas :: Int -> Int -> IO [Transacao]
getDespesas ano mes =  do
    transations <- (filterPorAnoMes ano mes)
    return (drop 1 (filter isDespesa transations))

-- Calcular o valor das receitas (créditos) em um determinado mês e ano.
calculateCredit :: Int -> Int -> IO Double
calculateCredit ano mes = do
    transations <- getReceitas ano mes
    return ((sum.(map valor)) transations)


calculateDebit :: Int -> Int -> IO Double
calculateDebit ano mes = do
    transations <- getDespesas ano mes
    return ((sum.(map valor)) transations)

