function evaluateDraws(input) {
  const compact = input.replace(/\s/g, '');
  if (!compact) return 0;
  const tokens = input.match(/\d+(?:\.\d*)?|\.\d+|[()+*\/-]/g) || [];
  if (tokens.join('') !== compact) {
    throw new SyntaxError('請只輸入數字與 + - * / ( )。');
  }
  let position = 0;

  function safeNumber(value) {
    if (!Number.isFinite(value) || Math.abs(value) > Number.MAX_SAFE_INTEGER) {
      throw new RangeError('算式數值超出安全計算範圍。');
    }
    return value;
  }

  function factor() {
    const token = tokens[position++];
    if (token === '+' || token === '-') {
      return (token === '-' ? -1 : 1) * factor();
    }
    if (token === '(') {
      const value = sum();
      if (tokens[position++] !== ')') throw new SyntaxError('請檢查算式的括號。');
      return value;
    }
    if (token === undefined || !/^[\d.]/.test(token)) {
      throw new SyntaxError('算式不完整，請檢查數字與運算符號。');
    }
    return safeNumber(Number(token));
  }

  function product() {
    let value = factor();
    while (tokens[position] === '*' || tokens[position] === '/') {
      const operator = tokens[position++];
      const right = factor();
      if (operator === '/' && right === 0) throw new RangeError('不能除以 0。');
      value = safeNumber(operator === '*' ? value * right : value / right);
    }
    return value;
  }

  function sum() {
    let value = product();
    while (tokens[position] === '+' || tokens[position] === '-') {
      const operator = tokens[position++];
      const right = product();
      value = safeNumber(operator === '+' ? value + right : value - right);
    }
    return value;
  }

  const value = sum();
  if (position !== tokens.length) throw new SyntaxError('請檢查算式的數字、運算符號與括號。');
  if (!Number.isSafeInteger(value) || value < 0) {
    throw new RangeError('抽數須為非負整數，且不可超出安全計算範圍。');
  }
  return value;
}

function showCalculation(inputId, outputId, calculate) {
  const input = document.getElementById(inputId);
  const output = document.getElementById(outputId);
  const errorElement = document.getElementById(inputId + '-error');
  try {
    if (input.validity.badInput) throw new RangeError('請輸入有效的數字。');
    const value = input.value.trim();
    const result = value ? calculate(value) : 0;
    if (!Number.isSafeInteger(result) || result < 0) {
      throw new RangeError('數值超出安全計算範圍，請減少抽數。');
    }
    output.textContent = (result === 0 ? 0 : result).toLocaleString('en-US');
    input.setAttribute('aria-invalid', 'false');
    errorElement.textContent = '';
  } catch (error) {
    if (!(error instanceof SyntaxError) && !(error instanceof RangeError)) throw error;
    output.textContent = '—';
    input.setAttribute('aria-invalid', 'true');
    errorElement.textContent = error.message;
  }
}

function calcDraws() {
  showCalculation('astrites', 'draws-from-astrites', function (value) {
    const astrites = Number(value);
    if (!Number.isSafeInteger(astrites) || astrites < 0) {
      throw new RangeError('請輸入 0 或以上的整數星聲。');
    }
    return Math.floor(astrites / 160);
  });
}

function calcAstrites() {
  showCalculation('draws', 'astrites-from-draws', function (value) {
    return evaluateDraws(value) * 160;
  });
}

function addDraws(amount) {
  const input = document.getElementById('draws');
  const value = input.value.trim();
  input.value = value ? value + ' + ' + amount : String(amount);
  calcAstrites();
}

calcDraws();
calcAstrites();
