using Gestion_Tareas.Objectos;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace Gestion_Tareas.AccesoDatos
{
    public class TareaDAL
    {
        private Conexion _conexion = new Conexion();

        // -------------------------------------------------------
        //  Insertar tarea  →  sp_InsertarTarea
        //  Retorna el nuevo TareaId
        // -------------------------------------------------------
        public int Insertar(TareaObj t)
        {
            using (var con = _conexion.ObtenerConexion())
            using (var cmd = new SqlCommand("sp_InsertarTarea", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@ProyectoId", t.ProyectoId);
                cmd.Parameters.AddWithValue("@Titulo", t.Titulo);
                cmd.Parameters.AddWithValue("@Descripcion", (object)t.Descripcion ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@AsignadoA", t.AsignadoA.HasValue ? (object)t.AsignadoA.Value : DBNull.Value);
                cmd.Parameters.AddWithValue("@EstadoTareaId", t.EstadoTareaId);
                cmd.Parameters.AddWithValue("@FechaLimite", t.FechaLimite.HasValue ? (object)t.FechaLimite.Value : DBNull.Value);
                cmd.Parameters.AddWithValue("@CreadoPor", t.CreadoPor);

                using (var dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                        return Convert.ToInt32(dr["TareaId"]);
                }
            }

            return 0;
        }

        // -------------------------------------------------------
        //  Actualizar tarea  →  sp_ActualizarTarea
        // -------------------------------------------------------
        public void Actualizar(TareaObj t)
        {
            using (var con = _conexion.ObtenerConexion())
            using (var cmd = new SqlCommand("sp_ActualizarTarea", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@TareaId", t.TareaId);
                cmd.Parameters.AddWithValue("@Titulo", t.Titulo);
                cmd.Parameters.AddWithValue("@Descripcion", (object)t.Descripcion ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@AsignadoA", t.AsignadoA.HasValue ? (object)t.AsignadoA.Value : DBNull.Value);
                cmd.Parameters.AddWithValue("@EstadoTareaId", t.EstadoTareaId);
                cmd.Parameters.AddWithValue("@FechaLimite", t.FechaLimite.HasValue ? (object)t.FechaLimite.Value : DBNull.Value);

                cmd.ExecuteNonQuery();
            }
        }

        // -------------------------------------------------------
        //  Eliminar lógico  →  sp_EliminarTarea  (estado = Cancelada)
        // -------------------------------------------------------
        public void Eliminar(int tareaId)
        {
            using (var con = _conexion.ObtenerConexion())
            using (var cmd = new SqlCommand("sp_EliminarTarea", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@TareaId", tareaId);
                cmd.ExecuteNonQuery();
            }
        }

        // -------------------------------------------------------
        //  Consultar con filtros  →  sp_ConsultarTareas
        // -------------------------------------------------------
        public List<TareaObj> Consultar(int? proyectoId = null, string titulo = null,
                                        int? asignadoA = null, int? estadoTareaId = null)
        {
            var lista = new List<TareaObj>();

            using (var con = _conexion.ObtenerConexion())
            using (var cmd = new SqlCommand("sp_ConsultarTareas", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@ProyectoId", proyectoId.HasValue ? (object)proyectoId.Value : DBNull.Value);
                cmd.Parameters.AddWithValue("@Titulo", (object)titulo ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@AsignadoA", asignadoA.HasValue ? (object)asignadoA.Value : DBNull.Value);
                cmd.Parameters.AddWithValue("@EstadoTareaId", estadoTareaId.HasValue ? (object)estadoTareaId.Value : DBNull.Value);

                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        lista.Add(new TareaObj
                        {
                            TareaId = (int)dr["TareaId"],
                            ProyectoId = (int)dr["ProyectoId"],
                            ProyectoNombre = dr["Proyecto"].ToString(),
                            Titulo = dr["Titulo"].ToString(),
                            Descripcion = dr["Descripcion"].ToString(),
                            AsignadoA = dr["AsignadoA"] == DBNull.Value
                                                    ? (int?)null
                                                    : (int)dr["AsignadoA"],
                            AsignadoANombre = dr["AsignadoANombre"].ToString(),
                            EstadoTareaId = (int)dr["EstadoTareaId"],
                            EstadoTareaNombre = dr["EstadoTarea"].ToString(),
                            FechaLimite = dr["FechaLimite"] == DBNull.Value
                                                    ? (DateTime?)null
                                                    : (DateTime)dr["FechaLimite"],
                            FechaCreacion = (DateTime)dr["FechaCreacion"],
                            TotalComentarios = Convert.ToInt32(dr["TotalComentarios"])
                        });
                    }
                }
            }

            return lista;
        }

        // -------------------------------------------------------
        //  Asignar tarea a usuario  →  sp_AsignarTarea
        // -------------------------------------------------------
        public void Asignar(int tareaId, int usuarioId)
        {
            using (var con = _conexion.ObtenerConexion())
            using (var cmd = new SqlCommand("sp_AsignarTarea", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@TareaId", tareaId);
                cmd.Parameters.AddWithValue("@UsuarioId", usuarioId);
                cmd.ExecuteNonQuery();
            }
        }

        // -------------------------------------------------------
        //  Insertar comentario  →  sp_InsertarComentario
        //  Retorna el nuevo ComentarioId
        // -------------------------------------------------------
        public int InsertarComentario(ComentarioObj c)
        {
            using (var con = _conexion.ObtenerConexion())
            using (var cmd = new SqlCommand("sp_InsertarComentario", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@TareaId", c.TareaId);
                cmd.Parameters.AddWithValue("@UsuarioId", c.UsuarioId);
                cmd.Parameters.AddWithValue("@Texto", c.Texto);

                using (var dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                        return Convert.ToInt32(dr["ComentarioId"]);
                }
            }

            return 0;
        }

        // -------------------------------------------------------
        //  Obtener comentarios de una tarea  →  sp_ObtenerComentariosPorTarea
        // -------------------------------------------------------
        public List<ComentarioObj> ObtenerComentarios(int tareaId)
        {
            var lista = new List<ComentarioObj>();

            using (var con = _conexion.ObtenerConexion())
            using (var cmd = new SqlCommand("sp_ObtenerComentariosPorTarea", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@TareaId", tareaId);

                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        lista.Add(new ComentarioObj
                        {
                            ComentarioId = (int)dr["ComentarioId"],
                            TareaId = tareaId,
                            Texto = dr["Texto"].ToString(),
                            FechaComentario = (DateTime)dr["FechaComentario"],
                            Autor = dr["Autor"].ToString(),
                            RolAutor = dr["RolAutor"].ToString()
                        });
                    }
                }
            }

            return lista;
        }

        // -------------------------------------------------------
        //  Obtener por ID (filtro en memoria sobre Consultar)
        // -------------------------------------------------------
        public TareaObj ObtenerPorId(int tareaId)
        {
            var lista = Consultar();
            return lista.Find(t => t.TareaId == tareaId);
        }
    }
}