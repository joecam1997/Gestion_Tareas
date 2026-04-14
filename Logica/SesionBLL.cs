using Gestion_Tareas.Objectos;
using System;
using System.Security.Cryptography;
using System.Text;
using System.Web;

namespace Gestion_Tareas.Logica
{
    public class SesionBLL
    {
        private const string NOMBRE_COOKIE = "GTSesion";
        private const int MINUTOS_EXPIRA = 30;

        // -------------------------------------------------------
        //  Genera el hash SHA-256 de una contraseña en texto plano
        // -------------------------------------------------------
        public static string HashSHA256(string texto)
        {
            texto = texto.Trim();

            using (var sha = SHA256.Create())
            {
                byte[] bytes = sha.ComputeHash(Encoding.UTF8.GetBytes(texto));
                var sb = new StringBuilder();
                foreach (byte b in bytes)
                    sb.Append(b.ToString("x2"));
                return sb.ToString();
            }
        }

        // -------------------------------------------------------
        //  Intenta autenticar al usuario.
        //  Retorna el UsuarioObj si es válido, null si falla.
        // -------------------------------------------------------
        public static UsuarioObj Autenticar(string login, string contrasenaPlana)
        {
            string hash = HashSHA256(contrasenaPlana);
            var dal = new UsuarioDAL();
            return dal.Autenticar(login, hash);
        }

        // -------------------------------------------------------
        //  Crea la cookie de sesión tras un login exitoso
        // -------------------------------------------------------
        public static void CrearSesion(HttpResponse response, UsuarioObj usuario)
        {
            var cookie = new HttpCookie(NOMBRE_COOKIE)
            {
                // Guardamos UsuarioId|Nombre|Apellido|Rol
                Value = $"{usuario.UsuarioId}|{usuario.Nombre}|{usuario.Apellido}|{usuario.RolNombre}",
                Expires = DateTime.Now.AddMinutes(MINUTOS_EXPIRA),
                HttpOnly = true   // no accesible desde JavaScript
            };

            response.Cookies.Add(cookie);
        }

        // -------------------------------------------------------
        //  Verifica si existe una sesión válida
        // -------------------------------------------------------
        public static bool HaySesion(HttpRequest request)
        {
            var cookie = request.Cookies[NOMBRE_COOKIE];
            return cookie != null && !string.IsNullOrEmpty(cookie.Value);
        }

        // -------------------------------------------------------
        //  Obtiene el UsuarioId almacenado en la cookie
        // -------------------------------------------------------
        public static int ObtenerUsuarioId(HttpRequest request)
        {
            var cookie = request.Cookies[NOMBRE_COOKIE];
            if (cookie == null) return 0;

            var partes = cookie.Value.Split('|');
            return partes.Length > 0 ? Convert.ToInt32(partes[0]) : 0;
        }

        // -------------------------------------------------------
        //  Obtiene el nombre completo almacenado en la cookie
        // -------------------------------------------------------
        public static string ObtenerNombreCompleto(HttpRequest request)
        {
            var cookie = request.Cookies[NOMBRE_COOKIE];
            if (cookie == null) return string.Empty;

            var partes = cookie.Value.Split('|');
            return partes.Length >= 3 ? $"{partes[1]} {partes[2]}" : string.Empty;
        }

        // -------------------------------------------------------
        //  Obtiene el Rol almacenado en la cookie
        // -------------------------------------------------------
        public static string ObtenerRol(HttpRequest request)
        {
            var cookie = request.Cookies[NOMBRE_COOKIE];
            if (cookie == null) return string.Empty;

            var partes = cookie.Value.Split('|');
            return partes.Length >= 4 ? partes[3] : string.Empty;
        }

        // -------------------------------------------------------
        //  Cierra la sesión eliminando la cookie
        // -------------------------------------------------------
        public static void CerrarSesion(HttpResponse response)
        {
            var cookie = new HttpCookie(NOMBRE_COOKIE)
            {
                Expires = DateTime.Now.AddDays(-1),
                HttpOnly = true
            };
            response.Cookies.Add(cookie);
        }
    }
}