using Gestion_Tareas.Logica;
using Gestion_Tareas.Objectos;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Gestion_Tareas.WebApp.Usuarios
{
    public partial class ListaUsuarios : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Proteger la página: si no hay sesión redirigir al login
            if (!SesionBLL.HaySesion(Request))
                Response.Redirect("~/WebApp/Login.aspx");

        }

        // -------------------------------------------------------
        //  Retorna el nombre del usuario en sesión (para el navbar)
        // -------------------------------------------------------
        [WebMethod]
        public static string ObtenerNombreSesion()
        {
            return SesionBLL.ObtenerNombreCompleto(HttpContext.Current.Request);
        }

        // -------------------------------------------------------
        //  Retorna los roles para el combo de filtros
        // -------------------------------------------------------
        [WebMethod]
        public static List<CatalogoObj> ObtenerRoles()
        {
            return new CatalogoDAL_Wrapper().ObtenerRoles();
        }

        // -------------------------------------------------------
        //  Consultar usuarios con filtros opcionales
        // -------------------------------------------------------
        [WebMethod]
        public static List<UsuarioObj> Consultar(string nombre, string apellido,
                                                  string cedula, int? rolId, bool? activo)
        {
            var bll = new UsuarioBLL();
            return bll.Consultar(
                string.IsNullOrEmpty(nombre) ? null : nombre,
                string.IsNullOrEmpty(apellido) ? null : apellido,
                string.IsNullOrEmpty(cedula) ? null : cedula,
                rolId,
                activo
            );
        }

        // -------------------------------------------------------
        //  Eliminar usuario (lógico)
        // -------------------------------------------------------
        [WebMethod]
        public static string Eliminar(int usuarioId)
        {
            try
            {
                new UsuarioBLL().Eliminar(usuarioId);
                return "Usuario desactivado correctamente.";
            }
            catch (Exception ex)
            {
                return "Error al desactivar: " + ex.Message;
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

    // Wrapper interno para acceder a CatalogoDAL desde un método estático
    internal class CatalogoDAL_Wrapper
    {
        public List<CatalogoObj> ObtenerRoles()
        {
            return new Gestion_Tareas.AccesoDatos.CatalogoDAL().ObtenerRoles();
        }
    }
}