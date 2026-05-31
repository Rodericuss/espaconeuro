defmodule EspacoNeuro.Contact do
  import Swoosh.Email

  alias EspacoNeuro.Mailer

  def send_contact_message(attrs) do
    clinic_email =
      Application.get_env(:espaco_neuro, :contact_email, "contato@espaconeuro.com.br")

    email =
      new()
      |> to(clinic_email)
      |> from({"Espaço Neuro Site", clinic_email})
      |> reply_to({attrs["name"], attrs["email"]})
      |> subject("Contato via site: #{attrs["name"]}")
      |> text_body("""
      Nova mensagem de contato pelo site Espaço Neuro:

      Nome: #{attrs["name"]}
      E-mail: #{attrs["email"]}
      Telefone: #{attrs["phone"] || "não informado"}

      Mensagem:
      #{attrs["message"]}
      """)

    Mailer.deliver(email)
  end

  def validate(attrs) do
    errors = []
    errors = if blank?(attrs["name"]), do: [{"name", "é obrigatório"} | errors], else: errors
    errors = if blank?(attrs["email"]), do: [{"email", "é obrigatório"} | errors], else: errors

    errors =
      if !blank?(attrs["email"]) && !String.contains?(attrs["email"], "@"),
        do: [{"email", "formato inválido"} | errors],
        else: errors

    errors =
      if blank?(attrs["message"]), do: [{"message", "é obrigatório"} | errors], else: errors

    case errors do
      [] -> :ok
      _ -> {:error, errors}
    end
  end

  defp blank?(nil), do: true
  defp blank?(str), do: String.trim(str) == ""
end
