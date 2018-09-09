defmodule Webdavex do
  @moduledoc """
  WebDAV client for elixir applications. See `Webdavex.Client`.

  Refer to `Webdavex.Config` for detailed information on available options.

  ## Examples

  ### General usage

      defmodule MyClient
        use Webdavex, base_url: "https://webdav.com/my_app"
      end

      MyClient.get("images/foobar.png")
      {:ok, ...}

  ### Dynamic config
  In order to change configuration during runtime you can wrap a client in `Agent`
  and override `config/0` to fetch data from its state.

      defmodule MyClient do
        use Agent
        use Webdavex, base_url: "https://webdav.com"

        def start_link do
          Agent.start_link(fn -> @config end, name: __MODULE__)
        end

        def update_config(map) do
          Agent.update(__MODULE__, Webdavex.Config.new(map))
        end

        def config do
          Agent.get(__MODULE__, fn config -> config end)
        end
      end

      {:ok, _pid} = MyClient.start_link()
      MyClient.update_config(%{base_url: "http://host", headers: [{"Foo", "bar}]})

      MyClient.get("images/foobar.png")
      {:ok, ...}
  """

  alias Webdavex.Client

  defmacro __using__(opts) do
    quote do
      Module.put_attribute(__MODULE__, :config, Webdavex.Config.new(unquote(opts)))

      @spec config :: Webdavex.Config.t()
      @doc "Returns webdav client configuration."
      def config, do: @config

      @spec get(path :: String.t()) :: {:ok, binary} | {:error, atom}
      def get(path), do: Client.get(config(), path)

      @spec put(path :: String.t(), {:file, file_path :: String.t()}) :: {:ok, :created | :updated} | {:error, atom}
      @spec put(path :: String.t(), {:binary, content :: binary}) :: {:ok, :created | :updated} | {:error, atom}
      def put(path, content), do: Client.put(config(), path, content)

      @spec move(source :: String.t(), dest :: String.t(), overwrite :: boolean) :: {:ok, :moved} | {:error, atom}
      def move(source, dest, overwrite \\ true), do: Client.move(config(), source, dest, overwrite)

      @spec copy(source :: String.t(), dest :: String.t(), overwrite :: boolean) :: {:ok, :copied} | {:error, atom}
      def copy(source, dest, overwrite \\ true), do: Client.copy(config(), source, dest, overwrite)

      @spec delete(path :: String.t()) :: {:ok, :deleted} | {:error, atom}
      def delete(path), do: Client.delete(config(), path)

      @spec mkcol(path :: String.t()) :: {:ok, :created} | {:error, atom}
      def mkcol(path), do: Client.mkcol(config(), path)

      @spec mkcol_recursive(path :: String.t()) :: {:ok, :created} | {:error, atom}
      def mkcol_recursive(path), do: Client.mkcol_recursive(config(), path)

      defoverridable config: 0
    end
  end
end