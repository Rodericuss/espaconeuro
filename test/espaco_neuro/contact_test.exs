defmodule EspacoNeuro.ContactTest do
  use ExUnit.Case, async: true

  alias EspacoNeuro.Contact

  describe "validate/1" do
    test "returns :ok with valid attrs" do
      attrs = %{"name" => "João", "email" => "joao@example.com", "message" => "Olá!"}
      assert :ok = Contact.validate(attrs)
    end

    test "returns errors when fields are blank" do
      attrs = %{"name" => "", "email" => "", "message" => ""}
      assert {:error, errors} = Contact.validate(attrs)
      assert {"name", "é obrigatório"} in errors
      assert {"email", "é obrigatório"} in errors
      assert {"message", "é obrigatório"} in errors
    end

    test "returns error for invalid email" do
      attrs = %{"name" => "João", "email" => "invalid", "message" => "Olá!"}
      assert {:error, errors} = Contact.validate(attrs)
      assert {"email", "formato inválido"} in errors
    end
  end
end
