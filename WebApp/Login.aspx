<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="Gestion_Tareas.WebApp.Login" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>GestorTareas — Ingresar</title>

    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Rajdhani:wght@400;600;700&family=Source+Sans+3:wght@300;400;600&display=swap" rel="stylesheet" />
    <!-- jQuery UI CSS -->
    <link href="https://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.min.css" rel="stylesheet" />
    <!-- Estilos globales -->
    <link href="Styles/site.css" rel="stylesheet" />

    <style>
        body {
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            background: var(--bg);
            background-image: radial-gradient(circle, #2a2f45 1px, transparent 1px);
            background-size: 28px 28px;
        }

        .login-wrap {
            width: 100%;
            max-width: 400px;
            padding: 1rem;
            animation: fadeUp 0.4s ease both;
        }

        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(20px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        .login-brand {
            text-align: center;
            margin-bottom: 1.75rem;
        }

        .login-brand .icon {
            width: 54px;
            height: 54px;
            background: var(--accent);
            border-radius: 14px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 0.75rem;
            box-shadow: 0 0 28px var(--accent-glow);
        }

        .login-brand .icon svg {
            width: 28px;
            height: 28px;
            stroke: #fff;
            fill: none;
            stroke-width: 2;
            stroke-linecap: round;
            stroke-linejoin: round;
        }

        .login-brand h1 {
            font-size: 1.8rem;
            letter-spacing: 0.08em;
            text-transform: uppercase;
            margin: 0;
        }

        .login-brand h1 span { color: var(--accent); }

        .login-brand p {
            color: var(--text-muted);
            font-size: 0.85rem;
            margin-top: 0.25rem;
        }

        .login-card {
            background: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: 10px;
            padding: 2rem;
            box-shadow: 0 20px 60px rgba(0,0,0,0.5);
        }

        .input-icon-wrap { position: relative; }

        .input-icon-wrap svg {
            position: absolute;
            left: 0.75rem;
            top: 50%;
            transform: translateY(-50%);
            width: 16px;
            height: 16px;
            stroke: var(--text-muted);
            fill: none;
            stroke-width: 2;
            stroke-linecap: round;
            stroke-linejoin: round;
            pointer-events: none;
        }

        .input-icon-wrap input { padding-left: 2.4rem !important; }

        #btnLogin {
            width: 100%;
            padding: 0.7rem;
            font-size: 1rem;
            justify-content: center;
            margin-top: 0.5rem;
        }

        .login-footer {
            text-align: center;
            margin-top: 1.25rem;
            color: var(--text-muted);
            font-size: 0.8rem;
        }

        .spinner {
            width: 15px;
            height: 15px;
            border: 2px solid rgba(255,255,255,0.3);
            border-top-color: #fff;
            border-radius: 50%;
            animation: spin 0.7s linear infinite;
            display: none;
        }

        @keyframes spin { to { transform: rotate(360deg); } }
    </style>
</head>
<body>
    <form id="form1" runat="server">

        <!-- ScriptManager: necesario para PageMethods -->
        <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true" />

        <div class="login-wrap">

            <!-- Marca -->
            <div class="login-brand">
                <div class="icon">
                    <svg viewBox="0 0 24 24">
                        <path d="M9 11l3 3L22 4"/>
                        <path d="M21 12v7a2 2 0 01-2 2H5a2 2 0 01-2-2V5a2 2 0 012-2h11"/>
                    </svg>
                </div>
                <h1>Gestor<span>Tareas</span></h1>
                <p>Sistema de Gestión de Proyectos</p>
            </div>

            <!-- Card del formulario -->
            <div class="login-card">

                <!-- Zona de alertas -->
                <div id="gt-alertas"></div>

                <!-- Usuario -->
                <div class="gt-form-group">
                    <label for="txtLogin">Usuario</label>
                    <div class="input-icon-wrap">
                        <svg viewBox="0 0 24 24">
                            <path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/>
                            <circle cx="12" cy="7" r="4"/>
                        </svg>
                        <input type="text" id="txtLogin"
                               placeholder="Ingrese su usuario"
                               title="Escriba su nombre de usuario del sistema"
                               autocomplete="username" />
                    </div>
                </div>

                <!-- Contraseña -->
                <div class="gt-form-group">
                    <label for="txtPass">Contraseña</label>
                    <div class="input-icon-wrap">
                        <svg viewBox="0 0 24 24">
                            <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                            <path d="M7 11V7a5 5 0 0110 0v4"/>
                        </svg>
                        <input type="password" id="txtPass"
                               placeholder="Ingrese su contraseña"
                               title="Escriba su contraseña de acceso"
                               autocomplete="current-password" />
                    </div>
                </div>

                <!-- Botón -->
                <button type="button" id="btnLogin" class="gt-btn gt-btn-primary" onclick="doLogin()">
                    <span class="spinner" id="spinner"></span>
                    <span id="btnText">Ingresar</span>
                </button>

            </div>

            <div class="login-footer">
                &copy; <%= DateTime.Now.Year %> GestorTareas &mdash; Todos los derechos reservados
            </div>

        </div><!-- /login-wrap -->

    </form>

    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-1.12.4.min.js"></script>
    <!-- jQuery UI -->
    <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.min.js"></script>
    <!-- JS propio -->
    <script src="Scripts/app.js"></script>

    <script>
        /* Enter dispara el login */
        $(function () {
            $(document).on("keypress", function (e) {
                if (e.which === 13) doLogin();
            });
        });

        function doLogin() {
            var login = $.trim($("#txtLogin").val());
            var pass  = $.trim($("#txtPass").val());

            if (!login || !pass) {
                gtMostrarAlerta("error", "&#9888; Por favor complete todos los campos.");
                return;
            }

            gtBloquearBtn("#btnLogin");
            $("#spinner").show();
            $("#btnText").text("Verificando...");

            PageMethods.Autenticar(login, pass,
                function (resultado) {
                    if (resultado === "OK") {
                        window.location.href = "Default.aspx";
                    } else {
                        gtMostrarAlerta("error", "&#10007; " + resultado);
                        gtDesbloquearBtn("#btnLogin");
                        $("#spinner").hide();
                        $("#btnText").text("Ingresar");
                        $("#txtPass").val("").focus();
                    }
                },
                function () {
                    gtMostrarAlerta("error", "&#9888; Error de conexión. Intente de nuevo.");
                    gtDesbloquearBtn("#btnLogin");
                    $("#spinner").hide();
                    $("#btnText").text("Ingresar");
                }
            );
        }
    </script>

</body>
</html>
