USE [iti_pro]
GO

CREATE Procedure [dbo].[Correct_Exam]
@Exam_ID INT , @St_SSN INT

As
Begin
	Begin Try
		
		Declare @Total INT
		Set @Total  = 0

			declare @Crs_ID int
			select distinct @Crs_ID = E.Course_ID
			from ExamQuestions EQ inner join Exam E 
			on EQ.Exam_ID = E.Exam_ID inner join Question Q
			on EQ.Ques_ID = Q.Ques_ID
			where E.Exam_ID = @Exam_ID
			

		Declare @Cerr_ID INT ;

		Declare Cur_ID Cursor
		For Select Ques_ID
			From Student_Answer
			Where Exam_ID = @Exam_ID AND St_SSN = @St_SSN;
		
		Open Cur_ID;

		Fetch Next From Cur_ID 
		Into @Cerr_ID;
		While @@FETCH_STATUS = 0 
			Begin 
				Declare @Student_Answer varchar(Max)
				Declare @Ques_Answer varchar(Max)
				Select @Student_Answer = SA.Answer , @Ques_Answer = Q.Answer
				From Student_Answer SA INNER JOIN Question Q
				ON SA.Ques_ID = Q.Ques_id
			Where Exam_ID = @Exam_ID AND SA.Ques_ID = @Cerr_ID AND St_SSN = @St_SSN
				IF @Student_Answer = @Ques_Answer
					BEGIN
						Update Student_Answer
						Set Grade = 2
						Where Exam_ID = @Exam_ID AND Ques_ID = @Cerr_ID AND St_SSN = @St_SSN
						Set @Total = @Total + 2
					END
				Else
					BEGIN
						Update Student_Answer
						Set Grade = 0
						Where Exam_ID = @Exam_ID AND Ques_ID = @Cerr_ID AND St_SSN = @St_SSN
					END
				FETCH NEXT FROM Cur_ID INTO 
				@Cerr_ID;
			End;
		Close Cur_ID;
		Deallocate Cur_ID;
					Select Concat (Fname,' ',Lname) As 'Student', Course_Name As 'Course Name',Concat (SUM(SA.Grade),'/','20') As 'Grade'
						From Student S INNER JOIN Stu_courses SC
						On S.St_SSN = SC.St_SSN
						INNER JOIN Course C 
						ON SC.Course_ID = C.Course_ID
						INNER JOIN Student_Answer SA
						ON SA.St_SSN = S.St_SSN
						Where SA.St_SSN = @St_SSN And C.Course_ID = @Crs_ID And SA.Exam_ID = @Exam_ID
						Group By  Concat (Fname,' ',Lname) ,Course_Name

		END Try
	BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
end
