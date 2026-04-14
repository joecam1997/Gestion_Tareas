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

namespace Gestion_Tareas.WebApp.Proyectos
{
    public partial class FormProyecto : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!SesionBLL.HaySesion(Request))
                Response.Redirect("~/WebApp/Login.aspx");
        }

        [WebMethod]
        public static string ObtenerNombreSesion()
        {
            return SesionBLL.ObtenerNombreCompleto(HttpContext.Current.Request);
        }

        [WebMethod]
        public static System.Collections.Generic.List<CatalogoObj> ObtenerEstadosProyecto()
        {
            return new CatalogoDAL().ObtenerEstadosProyecto();
        }

        // Devuelve DTO con fechas como string para evitar problemas de serialización
        [WebMethod]
        public static object ObtenerPorId(int proyectoId)
        {
            var p = new ProyectoBLL().ObtenerPorId(proyectoId);
            if (p == null) return null;

            return new
            {
                p.ProyectoId,
                p.Nombre,
                p.Descripcion,
                FechaInicioStr = p.FechaInicio.ToString("dd/MM/yyyy"),
                FechaFinStr = p.FechaFin.HasValue ? p.FechaFin.Value.ToString("dd/MM/yyyy") : null,
                p.EstadoProyectoId
            };
        }

        [WebMethod]
        public static string Guardar(int proyectoId, string nombre, string descripcion,
                                     string fechaInicio, string fechaFin, int estadoProyectoId)
        {
            try
            {
                DateTime inicio;
                if (!DateTime.TryParseExact(fechaInicio, "dd/MM/yyyy",
                        CultureInfo.InvariantCulture, DateTimeStyles.None, out inicio))
                    return "Formato de fecha de inicio inválido. Use dd/mm/aaaa.";

                DateTime? fin = null;
                if (!string.IsNullOrEmpty(fechaFin))
                {
                    DateTime finVal;
                    if (!DateTime.TryParseExact(fechaFin, "dd/MM/yyyy",
                            CultureInfo.InvariantCulture, DateTimeStyles.None, out finVal))
                        return "Formato de fecha de fin inválido. Use dd/mm/aaaa.";
                    fin = finVal;
                }

                var p = new ProyectoObj
                {
                    ProyectoId = proyectoId,
                    Nombre = nombre.Trim(),
                    Descripcion = string.IsNullOrEmpty(descripcion) ? null : descripcion.Trim(),
                    FechaInicio = inicio,
                    FechaFin = fin,
                    EstadoProyectoId = estadoProyectoId,
                    CreadoPor = SesionBLL.ObtenerUsuarioId(HttpContext.Current.Request)
                };

                var bll = new ProyectoBLL();
                int resultado;

                if (proyectoId == 0)
                    resultado = bll.Insertar(p);
                else
                {
                    resultado = bll.Actualizar(p);
                    if (resultado == 0) return "OK";
                }

                if (resultado == -1) return "La fecha de fin debe ser mayor o igual a la fecha de inicio.";
                return resultado > 0 ? "OK" : "No se pudo guardar el proyecto.";
            }
            catch (Exception ex)
            {
                return "Error inesperado: " + ex.Message;
            }
        }

        [WebMethod]
        public static void CerrarSesion()
        {
            SesionBLL.CerrarSesion(HttpContext.Current.Response);
        }
    }
}