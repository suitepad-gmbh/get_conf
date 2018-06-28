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

  test "get_conf/3 returns nil if there is no keyword list" do
    assert nil == GetConf.get_conf(:get_conf, FooModule, :base)
  end
end
