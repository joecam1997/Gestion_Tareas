using Gestion_Tareas.Logica;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Gestion_Tareas.WebApp
{
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Si ya tiene sesión activa, redirigir al inicio
            if (SesionBLL.HaySesion(Request))
                Response.Redirect("~/WebApp/Default.aspx");

        }
        [WebMethod]
        public static string Autenticar(string login, string contrasena)
        {
            try
            {
                var usuario = SesionBLL.Autenticar(login, contrasena);

                if (usuario == null)
                    return "Usuario o contraseña incorrectos.";

                // Crear cookie de sesión
                SesionBLL.CrearSesion(HttpContext.Current.Response, usuario);

                return "OK";
            }
            catch (Exception ex)
            {
                return ex.Message;
                // En producción loguear el error real; al usuario solo mensaje genérico
                //return "Error interno. Contacte al administrador.";
            }
        }
    }
}