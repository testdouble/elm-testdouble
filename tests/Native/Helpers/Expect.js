const _testdouble$elm_testdouble$Native_Helpers_Expect = (() => {
  const Ok = _elm_lang$core$Result$Ok;
  const Err = _elm_lang$core$Result$Err;

  function crash(testExecution) {
    try {
      testExecution();
      return Err('');
    } catch (e) {
      return Ok(e.message);
    }
  }

  return { crash };
})();
