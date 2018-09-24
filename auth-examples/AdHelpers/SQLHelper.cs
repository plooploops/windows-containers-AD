using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data;
using System.Data.SqlClient;
namespace AdHelpers
{
    public class SQLHelper
    {
        public static List<Result> GetTestData(string connection, string upn = null)
        {
            var res = new List<Result>();
            try
            {
                using (SqlConnection conn = new SqlConnection(connection))
                {
                    conn.Open();

                    SqlCommand cmd = new SqlCommand("Get_Test_Data", conn);

                    // 2. set the command object so it knows to execute a stored procedure
                    cmd.CommandType = CommandType.StoredProcedure;

                    // 3. add parameter to command, which will be passed to the stored procedure
                    cmd.Parameters.Add(new SqlParameter("@UPN", upn));

                    // execute the command
                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        // iterate through results, printing each to console
                        while (rdr.Read())
                        {
                            res.Add(new Result { name = rdr["Name"].ToString(), 
                                                 value = rdr["Value"].ToString()});
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("Unable to fetch data from db.");
                Console.WriteLine(ex.ToString());
            }

            return res;
        }
    }
}
