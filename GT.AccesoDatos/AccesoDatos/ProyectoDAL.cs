using Gestion_Tareas.Objectos;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace Gestion_Tareas.AccesoDatos
{
    public class ProyectoDAL
    {
        private Conexion _conexion = new Conexion();

        // -------------------------------------------------------
        //  Insertar  →  sp_InsertarProyecto
        //  Retorna el nuevo ProyectoId
        // -------------------------------------------------------
        public int Insertar(ProyectoObj p)
        {
            using (var con = _conexion.ObtenerConexion())
            using (var cmd = new SqlCommand("sp_InsertarProyecto", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@Nombre", p.Nombre);
                cmd.Parameters.AddWithValue("@Descripcion", (object)p.Descripcion ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@FechaInicio", p.FechaInicio);
                cmd.Parameters.AddWithValue("@FechaFin", p.FechaFin.HasValue ? (object)p.FechaFin.Value : DBNull.Value);
                cmd.Parameters.AddWithValue("@EstadoProyectoId", p.EstadoProyectoId);
                cmd.Parameters.AddWithValue("@CreadoPor", p.CreadoPor);

                using (var dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                        return Convert.ToInt32(dr["ProyectoId"]);
                }
            }

            return 0;
        }

        // -------------------------------------------------------
        //  Actualizar  →  sp_ActualizarProyecto
        // -------------------------------------------------------
        public void Actualizar(ProyectoObj p)
        {
            using (var con = _conexion.ObtenerConexion())
            using (var cmd = new SqlCommand("sp_ActualizarProyecto", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@ProyectoId", p.ProyectoId);
                cmd.Parameters.AddWithValue("@Nombre", p.Nombre);
                cmd.Parameters.AddWithValue("@Descripcion", (object)p.Descripcion ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@FechaInicio", p.FechaInicio);
                cmd.Parameters.AddWithValue("@FechaFin", p.FechaFin.HasValue ? (object)p.FechaFin.Value : DBNull.Value);
                cmd.Parameters.AddWithValue("@EstadoProyectoId", p.EstadoProyectoId);

                cmd.ExecuteNonQuery();
            }
        }

        // -------------------------------------------------------
        //  Eliminar lógico  →  sp_EliminarProyecto  (estado = Suspendido)
        // -------------------------------------------------------
        public void Eliminar(int proyectoId)
        {
            using (var con = _conexion.ObtenerConexion())
            using (var cmd = new SqlCommand("sp_EliminarProyecto", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ProyectoId", proyectoId);
                cmd.ExecuteNonQuery();
            }
        }

        // -------------------------------------------------------
        //  Consultar con filtros  →  sp_ConsultarProyectos
        // -------------------------------------------------------
        public List<ProyectoObj> Consultar(string nombre = null, int? estadoProyectoId = null)
        {
            var lista = new List<ProyectoObj>();

            using (var con = _conexion.ObtenerConexion())
            using (var cmd = new SqlCommand("sp_ConsultarProyectos", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@Nombre", (object)nombre ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@EstadoProyectoId", estadoProyectoId.HasValue
                                                                    ? (object)estadoProyectoId.Value
                                                                    : DBNull.Value);

                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        lista.Add(new ProyectoObj
                        {
                            ProyectoId = (int)dr["ProyectoId"],
                            Nombre = dr["Nombre"].ToString(),
                            Descripcion = dr["Descripcion"].ToString(),
                            FechaInicio = (DateTime)dr["FechaInicio"],
                            FechaFin = dr["FechaFin"] == DBNull.Value
                                                        ? (DateTime?)null
                                                        : (DateTime)dr["FechaFin"],
                            EstadoProyectoNombre = dr["Estado"].ToString(),
                            CreadoPorNombre = dr["CreadoPor"].ToString(),
                            FechaCreacion = (DateTime)dr["FechaCreacion"],
                            TotalTareas = Convert.ToInt32(dr["TotalTareas"]),
                            TareasCompletadas = Convert.ToInt32(dr["TareasCompletadas"])
                        });
                    }
                }
            }

            return lista;
        }

        // -------------------------------------------------------
        //  Obtener por ID  →  sp_ConsultarProyectos filtrando por ID
        //  (reutilizamos el SP de consulta con un filtro exacto de nombre
        //   no disponible; usamos el listado y filtramos, o creamos un SP aparte.
        //   Aquí usamos el Consultar y buscamos por ID en memoria.)
        // -------------------------------------------------------
        public ProyectoObj ObtenerPorId(int proyectoId)
        {
            // Traemos todos y filtramos — el SP no tiene filtro por ID.
            // Si en el futuro agregas sp_ObtenerProyectoPorId, reemplaza este método.
            var lista = Consultar();
            return lista.Find(p => p.ProyectoId == proyectoId);
        }
    }
}