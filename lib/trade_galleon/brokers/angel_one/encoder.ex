defmodule Encoder do
  defmacro __using__(opts) do
    encode_option = Keyword.get(opts, :encode, :camel_case)
    only_fields = Keyword.get(opts, :only, nil)
    except_fields = Keyword.get(opts, :except, [])

    quote do
      defimpl Jason.Encoder, for: __MODULE__ do
        def encode(struct, opts) do
          Jason.Encode.map(
            struct
            |> Map.take(unquote(only_fields) || Map.keys(struct))
            |> Map.drop([:__struct__ | unquote(except_fields)])
            |> Map.to_list()
            |> Enum.map(fn {k, v} ->
              case unquote(encode_option) do
                :camel_case ->
                  {(" " <> Atom.to_string(k)) |> Macro.camelize() |> String.trim(), v}

                :remove_underscore ->
                  {k
                   |> Atom.to_string()
                   |> String.replace("_", "")
                   |> String.to_atom(), v}

                :underscore ->
                  {Macro.underscore(Atom.to_string(k)), v}

                _ ->
                  raise "Invalid encoding option"
              end
            end)
            |> Enum.filter(fn {_, v} -> not is_nil(v) end)
            |> Enum.into(%{}),
            opts
          )
        end
      end
    end
  end

  def underscore_keys(map, field_mapper \\ fn x -> x end) do
    map
    |> Enum.map(fn
      {k, v} when is_binary(k) ->
        {k
         |> Macro.underscore()
         |> String.trim()
         |> String.to_atom()
         |> field_mapper.(), v}

      {k, v} ->
        {k
         |> Atom.to_string()
         |> Macro.underscore()
         |> String.trim()
         |> String.to_atom()
         |> field_mapper.(), v}
    end)
    |> Enum.into(%{})
  end
end
