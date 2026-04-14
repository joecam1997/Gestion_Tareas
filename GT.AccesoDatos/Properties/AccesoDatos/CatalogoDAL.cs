using Gestion_Tareas.Objectos;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace Gestion_Tareas.AccesoDatos
{
    public class CatalogoDAL
    {
        private Conexion _conexion = new Conexion();

        // -------------------------------------------------------
        //  Géneros  →  sp_ObtenerGeneros
        // -------------------------------------------------------
        public List<CatalogoObj> ObtenerGeneros()
        {
            var lista = new List<CatalogoObj>();

            using (var con = _conexion.ObtenerConexion())
            using (var cmd = new SqlCommand("sp_ObtenerGeneros", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        lista.Add(new CatalogoObj
                        {
                            Id = (int)dr["GeneroId"],
                            Descripcion = dr["Descripcion"].ToString()
                        });
                    }
                }
            }

            return lista;
        }

        // -------------------------------------------------------
        //  Estados Civiles  →  sp_ObtenerEstadosCiviles
        // -------------------------------------------------------
        public List<CatalogoObj> ObtenerEstadosCiviles()
        {
            var lista = new List<CatalogoObj>();

            using (var con = _conexion.ObtenerConexion())
            using (var cmd = new SqlCommand("sp_ObtenerEstadosCiviles", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        lista.Add(new CatalogoObj
                        {
                            Id = (int)dr["EstadoCivilId"],
                            Descripcion = dr["Descripcion"].ToString()
                        });
                    }
                }
            }

            return lista;
        }

        // -------------------------------------------------------
        //  Roles  →  sp_ObtenerRoles
        // -------------------------------------------------------
        public List<CatalogoObj> ObtenerRoles()
        {
            var lista = new List<CatalogoObj>();

            using (var con = _conexion.ObtenerConexion())
            using (var cmd = new SqlCommand("sp_ObtenerRoles", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        lista.Add(new CatalogoObj
                        {
                            Id = (int)dr["RolId"],
                            Descripcion = dr["Nombre"].ToString()
                        });
                    }
                }
            }

            return lista;
        }

        // -------------------------------------------------------
        //  Estados de Tarea  →  sp_ObtenerEstadosTarea
        // -------------------------------------------------------
        public List<CatalogoObj> ObtenerEstadosTarea()
        {
            var lista = new List<CatalogoObj>();

            using (var con = _conexion.ObtenerConexion())
            using (var cmd = new SqlCommand("sp_ObtenerEstadosTarea", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        lista.Add(new CatalogoObj
                        {
                            Id = (int)dr["EstadoTareaId"],
                            Descripcion = dr["Descripcion"].ToString()
                        });
                    }
                }
            }

            return lista;
        }

        // -------------------------------------------------------
        //  Estados de Proyecto  →  sp_ObtenerEstadosProyecto
        // -------------------------------------------------------
        public List<CatalogoObj> ObtenerEstadosProyecto()
        {
            var lista = new List<CatalogoObj>();

            using (var con = _conexion.ObtenerConexion())
            using (var cmd = new SqlCommand("sp_ObtenerEstadosProyecto", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        lista.Add(new CatalogoObj
                        {
                            Id = (int)dr["EstadoProyectoId"],
                            Descripcion = dr["Descripcion"].ToString()
                        });
                    }
                }
            }

            return lista;
        }
    }
}