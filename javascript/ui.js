const atualizaDados = () => {

    const mes_valor = document.getElementById("select-mes").value;
    const ano_valor = document.getElementById("select-ano").value;
    const mes = mes_valor !== "" ? Number(mes_valor) : "";
    const ano = ano_valor !== "" ? Number(ano_valor) : "";

    limpaSaidas();

    mapeiaDadosHistoricoTransacoes(ano, mes);
    ano !== "" && mes !== "" && mapeiaDadosFluxoCaixa(ano, mes);
    mapeiaRelatorios(ano, mes);

    controleDeExibicao(ano, mes);


}

const controleDeExibicao = (ano, mes) => {
    document.getElementById("relatorios-mes").style.display = (ano !== "" && mes !== "") ? "flex" : "none";
    document.getElementById("relatorios-ano").style.display = (ano !== "" && mes === "") ? "flex" : "none";
    document.getElementById("fluxo-caixa").style.display = (ano !== "" && mes !== "") ? "flex" : "none";
}

const limpaSaidas = () => {
    document.getElementById("transacoes").innerText = "";
    document.getElementById("fluxo").innerText = "";
    document.getElementById("valor-lucro").innerText = "-";
    document.getElementById("valor-despesa").innerText = "-";
    document.getElementById("valor-sobra").innerText = "-";
    document.getElementById("valor-saldo-final").innerText = "-";
    document.getElementById("valor-saldo-maximo").innerText = "-";
    document.getElementById("valor-saldo-minimo").innerText = "-";
    document.getElementById("media-lucro").innerText = "-";
    document.getElementById("media-despesa").innerText = "-";
    document.getElementById("media-sobra").innerText = "-";
}

const mapeiaRelatorios = (ano, mes) => {

    if (ano !== "" && mes !== "") {
        const lucro = filterIncomes(ano, mes);
        const despesas = filterExpenses(ano, mes);
        const sobras = getOver(ano, mes);
        const saldoFinal = getFinalBalance(ano, mes);
        const saldoMaximo = getMaxBalance(ano, mes).maxOrMinBalance;
        const saldoMinimo = getMinBalance(ano, mes).maxOrMinBalance;


        document.getElementById("valor-lucro").innerText = `R$ ${lucro.toFixed(2)}`;
        document.getElementById("valor-despesa").innerText = `R$ ${despesas.toFixed(2)}`;
        document.getElementById("valor-sobra").innerText = `R$ ${sobras.toFixed(2)}`;
        document.getElementById("valor-saldo-final").innerText = `R$ ${saldoFinal.toFixed(2)}`;
        document.getElementById("valor-saldo-final").innerText = `R$ ${saldoFinal.toFixed(2)}`;
        document.getElementById("valor-saldo-maximo").innerText = `R$ ${saldoMaximo.toFixed(2)}`;
        document.getElementById("valor-saldo-minimo").innerText = `R$ ${saldoMinimo.toFixed(2)}`;
    }


    else if (ano !== "") {
        const mediaLucro = getIncomesAverage(ano);
        const mediaDespesas = getExpensesAverage(ano);
        const mediaSobras = getOversAverage(ano);

        document.getElementById("media-lucro").innerText = `R$ ${mediaLucro.toFixed(2)}`;
        document.getElementById("media-despesa").innerText = `R$ ${mediaDespesas.toFixed(2)}`;
        document.getElementById("media-sobra").innerText = `R$ ${mediaSobras.toFixed(2)}`;
    }

}

const mapeiaDadosHistoricoTransacoes = (ano, mes) => {

    document.getElementById("transacoes").innerHTML = (mes !== "" ? filterTransactionByYearAndMonth(ano, mes) : filterTransactionByYear(ano)).

        map((transaction) => {
            const date = transaction.datas;

            return `<li class="list">` +
                `<h2 class="list-text"> ${transaction.textoIdentificador} </h2>` +
                `<h4 class="list-text">Descrição: ${transaction.descricao} </h4>` +
                `<h4 class="list-text">Data: ${date.dayOfMonth}/${date.month + 1}/${date.year} - ${date.hourOfDay} : ${date.minute}hrs </h4>` +
                `<h4 class="list-text">Valor: R$ ${transaction.valor} <h4>` +
                `<h4 class="list-text">Tipos da Transação: ${transaction.tipos}</h4>` +
                `<h4 class="list-text">Número Doc: ${transaction.numeroDOC}</h4>` +
                `</li>`

        }).join("");
}


const mapeiaDadosFluxoCaixa = (ano, mes) => {
    const dados = Object.values(getCashFlow(ano, mes));
    document.getElementById("fluxo").innerHTML = (ano !== "" && mes !== "" && dados) ? 
    dados.map((flow) => 
    `<li class="list-fluxo"> 
    <span class="dia">Dia: ${String(flow.dia).length === 1 ? 0 + String(flow.dia) : flow.dia}</span>
    <span class="list-text-fluxo">Saldo final do dia: R$ ${flow.saldoFinalDoDia.toFixed(2)}</span>
    </li>
    `).join("")
    
    : "";
}