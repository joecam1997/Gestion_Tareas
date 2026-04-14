using Gestion_Tareas.AccesoDatos;
using Gestion_Tareas.Logica;
using Gestion_Tareas.Objectos;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Gestion_Tareas.WebApp.Usuarios
{
    public partial class FormUsuario : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!SesionBLL.HaySesion(Request))
                Response.Redirect("~/WebApp/Login.aspx");
        }
    
     // -------------------------------------------------------
        //  Nombre de sesión para el navbar
        // -------------------------------------------------------
        [WebMethod]
        public static string ObtenerNombreSesion()
        {
            return SesionBLL.ObtenerNombreCompleto(HttpContext.Current.Request);
        }

        // -------------------------------------------------------
        //  Catálogos en un solo viaje al servidor
        // -------------------------------------------------------
        [WebMethod]
        public static object ObtenerCatalogos()
        {
            var dal = new CatalogoDAL();
            return new
            {
                Generos = dal.ObtenerGeneros(),
                EstadosCiviles = dal.ObtenerEstadosCiviles(),
                Roles = dal.ObtenerRoles()
            };
        }

        // -------------------------------------------------------
        //  Obtener usuario por ID para modo edición
        // -------------------------------------------------------
        [WebMethod]
        public static UsuarioObj ObtenerPorId(int usuarioId)
        {
            return new UsuarioBLL().ObtenerPorId(usuarioId);
        }

        // -------------------------------------------------------
        //  Guardar: inserta si usuarioId=0, actualiza si >0
        //  Retorna "OK" o mensaje de error descriptivo
        // -------------------------------------------------------
        [WebMethod]
        public static string Guardar(int usuarioId, string nombre, string apellido,
                                     string cedula, string fechaNac, int generoId,
                                     int estadoCivilId, int rolId,
                                     string loginUsuario, string contrasena)
        {
            try
            {
                // Parsear fecha dd/mm/yyyy
                DateTime fecha;
                if (!DateTime.TryParseExact(fechaNac, "dd/MM/yyyy",
                        CultureInfo.InvariantCulture, DateTimeStyles.None, out fecha))
                    return "Formato de fecha inválido. Use dd/mm/aaaa.";

                var u = new UsuarioObj
                {
                    UsuarioId = usuarioId,
                    Nombre = nombre.Trim(),
                    Apellido = apellido.Trim(),
                    Cedula = cedula.Trim(),
                    FechaNacimiento = fecha,
                    GeneroId = generoId,
                    EstadoCivilId = estadoCivilId,
                    RolId = rolId,
                    LoginUsuario = loginUsuario.Trim()
                };

                var bll = new UsuarioBLL();
                int resultado;

                if (usuarioId == 0)
                {
                    // Alta: contraseña requerida
                    resultado = bll.Insertar(u, contrasena);
                }
                else
                {
                    // Edición: si viene contraseña la actualizamos, si no la dejamos
                    if (!string.IsNullOrEmpty(contrasena))
                        u.Contrasena = SesionBLL.HashSHA256(contrasena);

                    resultado = bll.Actualizar(u);
                }

                switch (resultado)
                {
                    case -1: return "La cédula ya está registrada en otro usuario.";
                    case -2: return "El nombre de usuario (login) ya existe.";
                    case -3: return "La contraseña no cumple los requisitos mínimos (8 caracteres, mayúscula, número y carácter especial).";
                    case -4: return "La fecha de nacimiento no es válida (edad debe estar entre 10 y 100 años).";
                    default:
                        return resultado > 0 ? "OK" : "No se pudo guardar el registro.";
                }
            }
            catch (Exception ex)
            {
                return "Error inesperado: " + ex.Message;
            }
        }

        // -------------------------------------------------------
        //  Cerrar sesión
        // -------------------------------------------------------
        [WebMethod]
        public static void CerrarSesion()
        {
            SesionBLL.CerrarSesion(HttpContext.Current.Response);
        }
    }
}