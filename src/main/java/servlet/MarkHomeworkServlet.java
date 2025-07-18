package servlet;

import util.DBConnection;
import java.io.IOException;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;

public class MarkHomeworkServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Integer studentId = (Integer) request.getSession().getAttribute("studentId");
        int homeworkId = Integer.parseInt(request.getParameter("homeworkId"));

        try (Connection conn = DBConnection.getConnection()) {
            String checkSql = "SELECT * FROM homework_completion WHERE student_id=? AND homework_id=?";
            PreparedStatement checkStmt = conn.prepareStatement(checkSql);
            checkStmt.setInt(1, studentId);
            checkStmt.setInt(2, homeworkId);
            ResultSet rs = checkStmt.executeQuery();

            if (rs.next()) {
                String updateSql = "UPDATE homework_completion SET completed=1 WHERE student_id=? AND homework_id=?";
                PreparedStatement updateStmt = conn.prepareStatement(updateSql);
                updateStmt.setInt(1, studentId);
                updateStmt.setInt(2, homeworkId);
                updateStmt.executeUpdate();
            } else {
                String insertSql = "INSERT INTO homework_completion (student_id, homework_id, completed) VALUES (?, ?, 1)";
                PreparedStatement insertStmt = conn.prepareStatement(insertSql);
                insertStmt.setInt(1, studentId);
                insertStmt.setInt(2, homeworkId);
                insertStmt.executeUpdate();
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
        response.sendRedirect("homework.jsp");
    }
}