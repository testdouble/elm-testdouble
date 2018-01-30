const _testdouble$elm_testdouble$Native_TD = (() => {
  const td = require('testdouble');

  const Ok = _elm_lang$core$Result$Ok;
  const Err = _elm_lang$core$Result$Err;

  let originals = [];

  // Public
  // ======

  function function_(arity) {
    const thunk = () => td.function();
    thunk.func = null;
    thunk.arity = arity;
    return thunk;
  }

  function replace(arity, func) {
    const fakeableFunc = 'func' in func
      ? func.func
      : func;

    const thunk = () => td.function(fakeableFunc);
    thunk.func = func;
    thunk.arity = arity;
    thunk.original = fakeableFunc;
    return thunk;
  }

  function when1(thunk, a) {
    return when(thunk, a);
  }

  function when2(thunk, a, b) {
    return when(thunk, a, b);
  }

  function thenReturn(returnValue, thunk) {
    return copyThunk(thunk, () => thunk().thenReturn(returnValue));
  }

  function run1(thunk, test) {
    return run(A1, [thunk], test);
  }

  function run2(thunk1, thunk2, test) {
    return run(A2, [thunk1, thunk2], test);
  }

  function ready(thunk) {
    return copyThunk(thunk, () => {
      const fake = thunk();

      return (...args) => {
        let result = fake(...args);
        const resultIsUndefined = typeof result === 'undefined';

        if (resultIsUndefined && !thunk.original) {
          let explanation = td.explain(fake);

          explanation = {
            ...explanation,
            name: unmangleFunctionName(explanation.name),
          };

          throw new Error(
            `\nThis test double was called with an unexpected argument.\n\n${explanation.description}`
          );
        } else if (resultIsUndefined) {
          result = thunk.original(...args);
        }

        return result;
      };
    });
  }

  function verify1(fake, a) {
    return verify(fake, a);
  }

  // Helpers
  // =======

  function when(thunk, ...args) {
    const { func } = thunk;

    return copyThunk(thunk, () => {
      const fake = thunk();
      return td.when(fake(...args));
    });
  }

  function unmangleFunctionName(name) {
    if (!name) {
      return name;
    }

    const [,, ...pieces] = name.split('$');
    return pieces.join('.');
  }

  function run(applyer, thunks, test) {
    const fakes = thunks.map(consumeThunk);
    const result = applyer(test, ...fakes);

    reset();
    return result;
  }

  function consumeThunk(thunk) {
    const { func } = thunk;
    const fake = thunk();

    switch (thunk.arity) {
      case 1: {
        if (func) {
          originals.push({
            funcType: 'variable',
            func,
          });

          eval(`${func.name} = fake;`);
        }

        return fake;
      }

      case 2: {
        if (func) {
          const wrapper = func;

          originals.push({
            funcType: 'wrapper',
            func: wrapper.func,
            wrapper,
          })

          wrapper.func = fake;
        }

        return F2(fake);
      }
    }
  }

  function reset(arg) {
    originals.forEach(function(original) {
      if (original.funcType === 'variable') {
        eval(`${original.func.name} = original.func;`);
      } else {
        original.wrapper.func = original.func;
      }
    });

    originals = [];

    return arg;
  }

  function verify(fake, ...args) {
    try {
      td.verify(fake(...args));
      return Ok(true);
    } catch (e) {
      // TODO: clean this up and/or find better solution.

      const regex = /(Unsatisfied verification on test double )`(.*)`/;
      let error;
      let match;

      if (match = e.message.match(regex)) {
        const name = unmangleFunctionName(match[2]);
        error = e.message.replace(regex, `$1\`${name}\``);
      } else {
        error = e.message;
      }

      return Err(error);
    }
  }

  function copyThunk(thunk, newThunk) {
    newThunk.func = thunk.func;
    newThunk.arity = thunk.arity;
    newThunk.original = thunk.original;

    return newThunk;
  }

  function A1(f, arg) {
    return f(arg);
  }

  // API
  // ===

  return {
    function: function_,
    replace: F2(replace),
    when1: F2(when1),
    when2: F3(when2),
    thenReturn: F2(thenReturn),
    run1: F2(run1),
    run2: F3(run2),
    verify1: F2(verify1),
    ready,
  };
})();
