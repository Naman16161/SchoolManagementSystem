package servlet;

import util.DBConnection;
import java.io.IOException;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;

public class DeleteTimetableServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        String className = request.getParameter("class");
        String day = request.getParameter("day");

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "DELETE FROM timetable WHERE id=?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            throw new ServletException(e);
        }
        response.sendRedirect("manage_timetable.jsp?class=" + className + "&day=" + day);
    }
}