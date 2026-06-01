defmodule EspacoNeuroWeb.Router do
  use EspacoNeuroWeb, :router

  import EspacoNeuroWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {EspacoNeuroWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", EspacoNeuroWeb do
    pipe_through :browser

    live_session :public, layout: {EspacoNeuroWeb.Layouts, :public} do
      live "/", HomeLive, :index
      live "/servicos", ServicoLive.Index, :index
      live "/servicos/:slug", ServicoLive.Show, :show
      live "/equipe", EquipeLive.Index, :index
      live "/equipe/:slug", EquipeLive.Show, :show
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", EspacoNeuroWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:espaco_neuro, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: EspacoNeuroWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Admin routes (protected)

  scope "/admin", EspacoNeuroWeb.Admin do
    pipe_through [:browser, :require_authenticated_user]

    live_session :admin,
      on_mount: [{EspacoNeuroWeb.UserAuth, :require_authenticated}] do
      live "/", DashboardLive, :index
      live "/servicos", ServiceLive.Index, :index
      live "/servicos/new", ServiceLive.Form, :new
      live "/servicos/:id", ServiceLive.Show, :show
      live "/servicos/:id/edit", ServiceLive.Form, :edit

      live "/profissionais", ProfessionalLive.Index, :index
      live "/profissionais/new", ProfessionalLive.Form, :new
      live "/profissionais/:id", ProfessionalLive.Show, :show
      live "/profissionais/:id/edit", ProfessionalLive.Form, :edit
    end
  end

  ## Authentication routes

  scope "/", EspacoNeuroWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/log-in", UserSessionController, :new
    post "/users/log-in", UserSessionController, :create
  end

  scope "/", EspacoNeuroWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm-email/:token", UserSettingsController, :confirm_email
  end

  scope "/", EspacoNeuroWeb do
    pipe_through [:browser]

    delete "/users/log-out", UserSessionController, :delete
  end
end
