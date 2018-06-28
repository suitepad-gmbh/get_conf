defmodule GetConfTest do
  use ExUnit.Case
  doctest GetConf

  defmodule TestModule do
    use GetConf, otp_app: :get_conf
  end

  defmodule TestModule.Inner do
    use GetConf, otp_app: :get_conf
  end

  defmodule FooModule do
  end

  setup do
    Application.put_env(:get_conf, TestModule, foo: "bar", base: "jump")
    Application.put_env(:get_conf, TestModule.Inner, foo: "inner")
    Application.put_env(:get_conf, FooModule, "some string")

    on_exit(fn ->
      Application.delete_env(:get_conf, TestModule)
      Application.delete_env(:get_conf, TestModule.Inner)
      Application.delete_env(:get_conf, FooModule)
    end)
  end

  test "get_conf/1 fetches configuration from Application env for the current module" do
    assert "bar" == TestModule.get_conf(:foo)
    assert nil == TestModule.get_conf(:bar)
  end

  test "get_conf/1 fetches configuration from parent namespaces" do
    assert "inner" == TestModule.Inner.get_conf(:foo)
    assert nil == TestModule.Inner.get_conf(:bar)
    assert "jump" == TestModule.Inner.get_conf(:base)
  end

  test "set_conf/2 sets configuration for current module" do
    TestModule.Inner.set_conf(:foo, "bar")
    TestModule.Inner.set_conf(:meaning_of_live, 42)

    assert "bar" == TestModule.Inner.get_conf(:foo)
    assert 42 == TestModule.Inner.get_conf(:meaning_of_live)
    assert [meaning_of_live: 42, foo: "bar"] == Application.get_env(:get_conf, TestModule.Inner)
  end

  test "get_conf/3 returns nil if there is no keyword list" do
    assert nil == GetConf.get_conf(:get_conf, FooModule, :base)
    assert nil == GetConf.get_conf(:what_is_dat, FooModule, :base)
  end

  test "get_conf/3 raise error when invalid argument is passed" do
    assert_raise FunctionClauseError, fn ->
      GetConf.get_conf("wrong input", FooModule, :base)
    end
  end

  test "set_conf/4 puts a keyword list with a value in the application env for the module" do
    GetConf.set_conf(:get_conf, TestModule, :zig, "zag")

    assert "zag" == GetConf.get_conf(:get_conf, TestModule, :zig)
    assert [zig: "zag", foo: "bar", base: "jump"] = Application.get_env(:get_conf, TestModule)
  end

  test "set_conf/4 overrides the value of an existing key in the configuration" do
    GetConf.set_conf(:get_conf, TestModule, :foo, "zag")

    assert "zag" == GetConf.get_conf(:get_conf, TestModule, :foo)
    assert [foo: "zag", base: "jump"] = Application.get_env(:get_conf, TestModule)
  end

  test "set_conf/4 raises if the application env is not a list" do
    assert_raise RuntimeError, fn ->
      GetConf.set_conf(:get_conf, FooModule, :foo, "bar")
    end
  end
end
