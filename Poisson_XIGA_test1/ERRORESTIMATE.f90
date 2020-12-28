MODULE ERRORESTIMATE

	USE GEOMETRY
	USE NURBS_BASIS
	USE LOADFUNCTION
	USE GSQUAD

    IMPLICIT NONE
    
CONTAINS

!----MAX. NORM ESTIMATE----
SUBROUTINE MAXNORM(MAX_NORM, COEFF_SOL)

	REAL*8, INTENT(OUT) :: MAX_NORM(5)
	REAL*8, INTENT(IN) :: COEFF_SOL(DOF)
	TYPE(POINT2D) :: PHY_PT, REF_PT
	INTEGER :: II, I, J
	TYPE(POINT2D) :: EXDISP, APDISP, ERR_DISP, ERR_LINE_DISP, ERR_POLAR_DISP, TMP_ERR_DISP, MAXDISP
	TYPE(STRESS) :: EXSTR, APSTR, ERR_STR, TMP_ERR_STR, ERR_LINE_STR, ERR_POLAR_STR
	REAL*8 :: R, THETA
	INTEGER :: PATCH
	
	ERR_STR = STRESS(0.D0,0.D0,0.D0,0.D0,0.D0)
	ERR_DISP = POINT2D(0.D0,0.D0)
	MAXDISP = POINT2D(0.D0,0.D0)

	OPEN(11, FILE = './data/ext_disp')
	OPEN(21, FILE = './data/app_disp')
	OPEN(31, FILE = './data/err_disp')
	OPEN(41, FILE = './data/outerdisk')
	OPEN(51, FILE = './data/innerdisk')
	DO PATCH = 2, 2
		DO J = 1, 101
			DO I = 1, 100
				IF (PATCH==1) THEN
					REF_PT = POINT2D((1.D0*(I-1))/100.D0, (1.D0*(J-1))/100.D0)
					PHY_PT = GET_PHY_PT(REF_PT, PATCH)
					CALL GET_RTHETA(R, THETA, PHY_PT)
					IF (R.GT.0.55D0) THEN
						IF(DABS(PHY_PT%Y).LE.EPS .AND. PHY_PT%X.GE.EPS) THEN
							EXDISP%X = 0.D0; APDISP%X = 0.D0
						ELSE
							CALL APPROXSOL(APDISP, REF_PT, COEFF_SOL, PATCH)
							EXDISP = EX_DISP(REF_PT,PATCH)
						ENDIF
						TMP_ERR_DISP%X = DABS(EXDISP%X - APDISP%X)
						WRITE(11,*) PHY_PT, EXDISP%X
						WRITE(21,*) PHY_PT, APDISP%X
						WRITE(31,*) PHY_PT, TMP_ERR_DISP%X
						WRITE(41,*) PHY_PT, EXDISP%X, APDISP%X, TMP_ERR_DISP%X
						IF (TMP_ERR_DISP%X.GE.ERR_DISP%X) THEN
							ERR_DISP%X = TMP_ERR_DISP%X
						ENDIF
						IF (DABS(EXDISP%X).GE.MAXDISP%X) THEN
							MAXDISP%X = DABS(EXDISP%X)
						ENDIF
					ENDIF
				ELSEIF (PATCH==2) THEN
					REF_PT = POINT2D((1.D0*I)/101.D0, (1.D0*(J-1))/100.D0)
					PHY_PT = GET_PHY_PT(REF_PT, PATCH)
					IF(DABS(PHY_PT%Y).LE.EPS .AND. PHY_PT%X.GE.EPS) THEN
						EXDISP%X = 0.D0; APDISP%X = 0.D0
					ELSE
						CALL APPROXSOL(APDISP, REF_PT, COEFF_SOL, PATCH)
						EXDISP = EX_DISP(REF_PT,PATCH)
					ENDIF
					TMP_ERR_DISP%X = DABS(EXDISP%X - APDISP%X)
					WRITE(11,*) PHY_PT, EXDISP%X
					WRITE(21,*) PHY_PT, APDISP%X
					WRITE(31,*) PHY_PT, TMP_ERR_DISP%X
					WRITE(51,*) PHY_PT, EXDISP%X, APDISP%X, TMP_ERR_DISP%X
					IF (TMP_ERR_DISP%X.GE.ERR_DISP%X) THEN
						ERR_DISP%X = TMP_ERR_DISP%X
					ENDIF
					IF (DABS(EXDISP%X).GE.MAXDISP%X) THEN
						MAXDISP%X = DABS(EXDISP%X)
					ENDIF
				ENDIF
			ENDDO
			WRITE(11,*) ""
			WRITE(21,*) ""
			WRITE(31,*) ""
			WRITE(41,*) ""
			WRITE(51,*) ""
		ENDDO
		WRITE(11,*) ""
		WRITE(21,*) ""
		WRITE(31,*) ""
		WRITE(41,*) ""
		WRITE(51,*) ""
	ENDDO
	CLOSE(11)
	CLOSE(21)
	CLOSE(31)
	CLOSE(41)
	CLOSE(51)
	
! 	write(char_problem,fmt='(i1)') PROBLEM
! 	write(char_order(1),fmt='(i2.2)') GEO_ORDER(1)
! 	write(char_order(2),fmt='(i2.2)') GEO_ORDER(2)
! 	write(char_basis(1),fmt='(i2.2)') NUMBS(1)
! 	write(char_basis(2),fmt='(i2.2)') NUMBS(2)
! 
! 	filename = trim('./data/pro') // char_problem // trim('_') // trim('result_p') // char_order(1) // trim('X') // char_order(2) // trim('_b') // char_basis(1) // trim('X') // char_basis(2)

! 	open(13,file=filename,status='unknown')
! 	WRITE(13,*) "ORDER OF B-SPLINE : ", GEO_ORDER
! 	IF (EXTRA_KNOTS(1).EQ.0 .AND. EXTRA_KNOTS(2).EQ.0) THEN
! 		WRITE(13,*) "KNOT INSERTION : NONE"
! 	ELSE
! 		WRITE(13,*) "KNOT INSERTION : ", EXTRA_KNOTS
! 	ENDIF
! 	WRITE(13,*) "BOUNDARY CONDITION : ", BCTYPE
! 	WRITE(13,*) "NUMBER OF BASIS FTS : ", NUMBS
! 	WRITE(13,*) 'DEGREE OF FREEDOM : ', DOF - BD_DOF
! 	WRITE(13,*) 'DEGREE OF FREEDOM ON BOUNDARY : ', BD_DOF
! 	WRITE(13,*) ""
! 	WRITE(13,*) "MAXIMUM ERROR (%) : ", ERR_DISP%X*100.D0
! 	CLOSE(13)

	MAX_NORM(1) = ERR_DISP%X*100.D0/MAXDISP%X
	
END SUBROUTINE MAXNORM

SUBROUTINE ENRGY(ENRG, DMY_K, SOL)

	REAL*8, INTENT(IN) :: DMY_K(DOF,DOF), SOL(DOF)
	REAL*8, INTENT(OUT) :: ENRG(4)
	REAL*8 :: AP, TR
	INTEGER :: I, J

	AP = 0.50D0*DOT_PRODUCT(SOL, MATMUL(DMY_K, SOL))

	IF (PROBLEM.EQ.1) THEN
		TR = 2.D0/3.D0
	ELSEIF (PROBLEM.EQ.2) THEN
		TR = 0.785398163397448280D0
	ENDIF

! 	CALL EXT_ENERGY(TR)

	ENRG(3) = DSQRT(DABS(AP - TR))*100.D0
	ENRG(4) = DSQRT(DABS(AP - TR) / TR)*100.D0

	ENRG(1) = TR; ENRG(2) = AP

!   OPEN(13, FILE=filename, STATUS='unknown', POSITION='append')
! 	WRITE(13,*) ''
! 	WRITE(13,*) 'EXACT ENERGY : ', ENRG(1)
! 	WRITE(13,*) 'APPR. ENERGY : ', ENRG(2)
! 	WRITE(13,*) 'ABS.  ENERGY NORM ERROR (%) : ', ENRG(3)
! 	WRITE(13,*) 'REL.  ENERGY NORM ERROR (%) : ', ENRG(4)
! 	CLOSE(13)
! 

	WRITE(*,*) ""
	WRITE(*,*) 'APPR. ENERGY : ', AP
	PRINT*, ""
	PRINT*, 'REL.  ENERGY NORM ERROR (%) : ', ENRG(4)
	PRINT*, ""


END SUBROUTINE ENRGY

SUBROUTINE L2_NORM_ERROR(L2_NORM, COEFF_SOL)
	
	REAL*8, INTENT(OUT) :: L2_NORM(2)
	REAL*8, INTENT(IN) :: COEFF_SOL(DOF)
	INTEGER :: I, J, II, JJ, SUB_NUMLN(2), N, KK, K, PATCH
	REAL*8 :: SUB_LN_LENGTH(2), WEIGHT, DIFF_NN, DET_M
	TYPE(VEC2D) :: SUB_LN
	TYPE(POINT2D) :: GSPT, DMY_GSPT, PHY_PT
	TYPE(MATRIX_22) :: JACOB
	TYPE(POINT2D) :: EXDISP, APDISP, INTF(2)
	TYPE(STRESS) :: APSTRESS
	
	N = NUMGSPT
	SUB_NUMLN = (/1,1/)
	INTF(:) = POINT2D(0.D0,0.D0)
	
	DO PATCH = 1, 2
		DO JJ = 1, NUMIR(PATCH,1)-1
			SUB_LN_LENGTH(1) = DABS(IR_GRID(PATCH,1,JJ+1) - IR_GRID(PATCH,1,JJ))/(1.D0*SUB_NUMLN(1))
			DO J=1, SUB_NUMLN(1)
				CALL GAULEG(IR_GRID(PATCH,1,JJ)+(J-1)*SUB_LN_LENGTH(1), IR_GRID(PATCH,1,JJ)+J*SUB_LN_LENGTH(1), GSX, GSXW, N)
				DO II = 1, NUMIR(PATCH,2)-1
					SUB_LN_LENGTH(2) = DABS(IR_GRID(PATCH,2,II+1) - IR_GRID(PATCH,2,II))/(1.D0*SUB_NUMLN(2))
					DO I = 1, SUB_NUMLN(2)
						CALL GAULEG(IR_GRID(PATCH,2,II)+(I-1)*SUB_LN_LENGTH(2), IR_GRID(PATCH,2,II)+I*SUB_LN_LENGTH(2), GSY, GSYW, N)
						DO KK = 1, N
							DO K = 1, N
								GSPT = POINT2D(GSX(KK),GSY(K))
								DMY_GSPT = GSPT
								JACOB= GET_JACOBIAN_MATRIX(DMY_GSPT,PATCH)
								DET_M = .DETERMINANT.JACOB
	! 							PHY_PT = GET_PHY_PT(DMY_GSPT)
								EXDISP = EX_DISP(DMY_GSPT,1)
								CALL APPROXSOL(APDISP, DMY_GSPT, COEFF_SOL, PATCH)
								INTF(1)%X = INTF(1)%X + (EXDISP%X - APDISP%X)**2*DET_M*GSXW(KK)*GSYW(K)
	! 							INTF(1)%Y = INTF(1)%Y + (EXDISP%Y - APDISP%Y)**2*DET_M*GSXW(KK)*GSYW(K)
								INTF(2)%X = INTF(2)%X + EXDISP%X**2*DET_M*GSXW(KK)*GSYW(K)
	! 							INTF(2)%Y = INTF(2)%Y + EXDISP%Y**2*DET_M*GSXW(KK)*GSYW(K)
							ENDDO
						ENDDO
					ENDDO
				ENDDO
			ENDDO
		ENDDO
	ENDDO
	
	L2_NORM(1) = DSQRT(INTF(1)%X/INTF(2)%X)*100.D0
! 	L2_NORM(2) = DSQRT(INTF(1)%Y/INTF(2)%Y)*100.D0
	
! 	OPEN(13, FILE=filename, STATUS='unknown', POSITION='append')
! 	WRITE(13,*) ''
! 	WRITE(13,*) 'RELATIVE ERROR IN L2 NORM (%) OF DISPLACEMENT ALONG X-DIRECTION : ', L2_NORM(1)
! 	WRITE(13,*) 'RELATIVE ERROR IN L2 NORM (%) OF DISPLACEMENT ALONG Y-DIRECTION : ', L2_NORM(2)
! 	CLOSE(1)
	
END SUBROUTINE L2_NORM_ERROR

SUBROUTINE APPROXSOL(APDISP, REF_PT, COEFF_SOL, PATCH)

	TYPE(POINT2D), INTENT(IN) :: REF_PT
	REAL*8, INTENT(IN) :: COEFF_SOL(DOF)
	INTEGER, INTENT(IN) :: PATCH
	TYPE(POINT2D), INTENT(OUT) :: APDISP

	TYPE(FVALUE) :: SF(DOF), LOCAL_SF1((BASIS_KVEC(1,1)%POLY_ORDER+1)*(BASIS_KVEC(1,2)%POLY_ORDER+1))
	TYPE(FVALUE) :: LOCAL_SF2((BASIS_KVEC(2,1)%POLY_ORDER+1)*(BASIS_KVEC(2,2)%POLY_ORDER+1))
	INTEGER :: I, J, II, JJ, KK, GLOBAL_INDX
	TYPE(INT2D) :: INDX1((BASIS_KVEC(1,1)%POLY_ORDER+1)*(BASIS_KVEC(1,2)%POLY_ORDER+1))
	TYPE(INT2D) :: INDX2((BASIS_KVEC(2,1)%POLY_ORDER+1)*(BASIS_KVEC(2,2)%POLY_ORDER+1))
	TYPE(POINT2D) :: PHY_PT, PHYPT_F, PHYPT_G, INV_PHYPT_F, INV_PHYPT_G
	TYPE(MATRIX_22) :: JACOB
	REAL*8 :: DET_M

	APDISP = POINT2D(0.D0, 0.D0)
	SF(:) = FVALUE(0.D0,0.D0,0.D0,0.D0,0.D0,0.D0)
	LOCAL_SF1(:) = FVALUE(0.D0,0.D0,0.D0,0.D0,0.D0,0.D0)
	LOCAL_SF2(:) = FVALUE(0.D0,0.D0,0.D0,0.D0,0.D0,0.D0)
	INDX1(:) = INT2D(0,0)
	INDX2(:) = INT2D(0,0)
	
	IF (PATCH==1) THEN
		JACOB = GET_JACOBIAN_MATRIX(REF_PT, 1)
		
		CALL GET_ALL_PHY_NURBS_SURFACE_2D(LOCAL_SF1, INDX1, REF_PT, JACOB, 1)
		
		DO JJ=1, UBOUND(INDX1,1)
			DO II = 1, LOCAL_DOF(1)
				IF (NDX(1,II).EQ.INDX1(JJ)%A .AND. NDX(2,II).EQ.INDX1(JJ)%B) THEN
					GLOBAL_INDX = II
					GOTO 111
				ENDIF
			ENDDO
			111 CONTINUE
			SF(GLOBAL_INDX) = LOCAL_SF1(JJ)
		ENDDO
		
! 		PRINT*, 'APP - HERE1'
! 	PHYPT_G = GET_PHY_PT(REF_PT, 1)
! 
! 	IF (DSQRT(PHYPT_G%X**2 + PHYPT_G%Y**2).LE.0.6D0) THEN
! 		INV_PHYPT_F = GET_REF_PT(PHYPT_G, 2)
! 		PRINT*, PHYPT_G, INV_PHYPT_F
! ! 		JACOB = GET_JACOBIAN_MATRIX(INV_PHYPT_F, 2)
! 		CALL GET_ALL_PHY_BASIS_IN_INT(LOCAL_SF2, INDX2, INV_PHYPT_F, JACOB, 2)
! 		DO JJ=1, UBOUND(INDX2,1)
! 			DO II = LOCAL_DOF(1)+1, DOF
! 				IF (NDX(1,II).EQ.INDX2(JJ)%A .AND. NDX(2,II).EQ.INDX2(JJ)%B) THEN
! 					GLOBAL_INDX = II
! 					GOTO 222
! 				ENDIF
! 			ENDDO
! 			222 CONTINUE
! 			SF(GLOBAL_INDX) = LOCAL_SF2(JJ)
! 		ENDDO
! 	ENDIF

	LOCAL_SF1(:) = FVALUE(0.D0,0.D0,0.D0,0.D0,0.D0,0.D0)
	INDX1(:) = INT2D(0,0)
	
	ELSEIF (PATCH==2) THEN
		JACOB = GET_JACOBIAN_MATRIX(REF_PT, 2)
		
		CALL GET_ALL_PHY_BASIS_IN_INT(LOCAL_SF2, INDX2, REF_PT, JACOB, 2)
	
		DO JJ=1, UBOUND(INDX2,1)
			DO II = LOCAL_DOF(1) + 1, DOF
				IF (NDX(1,II).EQ.INDX2(JJ)%A .AND. NDX(2,II).EQ.INDX2(JJ)%B) THEN
					GLOBAL_INDX = II
					GOTO 222
				ENDIF
			ENDDO
			222 CONTINUE
			SF(GLOBAL_INDX) = LOCAL_SF2(JJ)
		ENDDO
	
! 		PRINT*, 'APP - HERE2'

		PHYPT_F = GET_PHY_PT(REF_PT, 2)
		INV_PHYPT_G = GET_REF_PT(PHYPT_F, 1)

		CALL GET_ALL_PHY_NURBS_SURFACE_2D(LOCAL_SF1, INDX1, INV_PHYPT_G, JACOB, 1)
		DO JJ=1, UBOUND(INDX1,1)
			DO II = 1, LOCAL_DOF(1)
				IF (NDX(1,II).EQ.INDX1(JJ)%A .AND. NDX(2,II).EQ.INDX1(JJ)%B) THEN
					GLOBAL_INDX = II
					GOTO 333
				ENDIF
			ENDDO
			333 CONTINUE
			SF(GLOBAL_INDX) = LOCAL_SF1(JJ)
		ENDDO
	ENDIF
	
! 	PRINT*, 'APP - HERE3'
	
	APDISP%X = DOT_PRODUCT(COEFF_SOL(1:DOF), SF(:)%D00)
	
END SUBROUTINE APPROXSOL

SUBROUTINE BUGKILLER(STIF_K, STIF_F)

	REAL*8, INTENT(IN) :: STIF_K(DOF,DOF), STIF_F(DOF)
	
	REAL*8 :: STIF_INT(3), LOAD_INT, BD_INT(3), WEIGHT(NUMGSPT**2), BD_WEIGHT(NUMGSPT), DET_JF, DET_M
	TYPE(POINT2D) :: LOAD_F(NUMGSPT**2), GSPT, DMY_GSPT, PHYPT_F, INV_PHYPT_G
	TYPE(POINT2D) :: EXBD(NUMGSPT)
	TYPE(FVALUE) :: STIF_SF(NUMGSPT**2), BD_SF(2,NUMGSPT), STIF_I(NUMGSPT**2), STIF_J(NUMGSPT**2)
	INTEGER :: I, J, K, II, JJ, KK, PATCH
	TYPE(MATRIX_22) :: JACOB_F, JACOB_G, INV_JACOB_F, INV_JACOB_F_SQUARE, JACOB_FG, JACOB
	
	BD_INT(:) = 0.D0
	STIF_SF(:) = FVALUE(0.D0,0.D0,0.D0,0.D0,0.D0,0.D0)
	STIF_I(:) = FVALUE(0.D0,0.D0,0.D0,0.D0,0.D0,0.D0)
	STIF_J(:) = FVALUE(0.D0,0.D0,0.D0,0.D0,0.D0,0.D0)
	BD_SF(:,:) = FVALUE(0.D0,0.D0,0.D0,0.D0,0.D0,0.D0)
	STIF_INT(:) = 0.D0; LOAD_INT = 0.D0
	
	!----- CHECK STIFFNESS MATRIC -----!
	! (1) STIF_K (27,8), STIF_F(8)

	CALL GAULEG(0.D0, 0.25D0, GSX, GSXW, NUMGSPT)
	CALL GAULEG(0.D0, 0.9D0, GSY, GSYW, NUMGSPT)
	
! 	PRINT*, 'BUG - HERE1'
	
	KK=0
	DO I=1,NUMGSPT
		DO J=1,NUMGSPT
			KK=KK+1
! 			PRINT*, I, J
			GSPT = POINT2D(GSX(I), GSY(J))
			DMY_GSPT = GSPT
			PHYPT_F = GET_PHY_PT(DMY_GSPT,2)
! 			PRINT*, PHYPT_F
			INV_PHYPT_G = GET_REF_PT(PHYPT_F,1)
			
! 			PRINT*, INV_PHYPT_G
			
			JACOB_F = GET_JACOBIAN_MATRIX(DMY_GSPT,2)
			JACOB_G = GET_JACOBIAN_MATRIX(INV_PHYPT_G,1)
			
			DET_JF = .DETERMINANT.JACOB_F
			WEIGHT(KK) = DET_JF*GSXW(I)*GSYW(J)
! 			PRINT*, 'STIF_LC_INT_IN - HERE0'
			STIF_I(KK) = GET_PHY_BASIS_IN_INT(INV_PHYPT_G, 1, 2, JACOB_G, 1)
! 			CALL GET_ALL_PHY_NURBS_SURFACE_2D(SF1(KK,:), INDX1(:), INV_PHYPT_G, JACOB_FG, 1, 'INV')
! 			PRINT*, 'STIF_LC_INT_IN - HERE1'
			STIF_J(KK) =  GET_PHY_BASIS_IN_INT(DMY_GSPT, 2, 1, JACOB_F, 2)
! 			CALL GET_ALL_PHY_BASIS_IN_INT(SF2(KK,:), INDX2(:), DMY_GSPT, JACOB_F, 2)
! 			PRINT*, 'STIF_LC_INT_IN - HERE2'
		ENDDO
	ENDDO
	
! 	PRINT*, 'BUG - HERE2'
	
	STIF_INT(1) = DOT_PRODUCT(PRODUCT(RESHAPE((/STIF_I(:)%D10, WEIGHT(:)/), (/NUMGSPT**2, 2/), ORDER=ORDER1), 2), STIF_J(:)%D10)
	STIF_INT(2) = DOT_PRODUCT(PRODUCT(RESHAPE((/STIF_I(:)%D01, WEIGHT(:)/), (/NUMGSPT**2, 2/), ORDER=ORDER1), 2), STIF_J(:)%D01)
	STIF_INT(3) = STIF_INT(3) + SUM(STIF_INT(1:2))

	CALL GAULEG(0.25D0, 0.5D0, GSX, GSXW, NUMGSPT)
	CALL GAULEG(0.D0, 0.9D0, GSY, GSYW, NUMGSPT)
	
	KK=0
	DO I=1,NUMGSPT
		DO J=1,NUMGSPT
			KK=KK+1
! 			PRINT*, I, J
			GSPT = POINT2D(GSX(I), GSY(J))
			DMY_GSPT = GSPT
			PHYPT_F = GET_PHY_PT(DMY_GSPT,2)
! 			PRINT*, PHYPT_F
			INV_PHYPT_G = GET_REF_PT(PHYPT_F,1)
			
! 			PRINT*, INV_PHYPT_G
			
			JACOB_F = GET_JACOBIAN_MATRIX(DMY_GSPT,2)
			JACOB_G = GET_JACOBIAN_MATRIX(INV_PHYPT_G,1)
			
			INV_JACOB_F = .INVERSE.JACOB_F
			
			INV_JACOB_F_SQUARE%ENT(1,1) = DOT_PRODUCT(INV_JACOB_F%ENT(1,:), INV_JACOB_F%ENT(:,1))
			INV_JACOB_F_SQUARE%ENT(1,2) = DOT_PRODUCT(INV_JACOB_F%ENT(1,:), INV_JACOB_F%ENT(:,2))
			INV_JACOB_F_SQUARE%ENT(2,1) = DOT_PRODUCT(INV_JACOB_F%ENT(2,:), INV_JACOB_F%ENT(:,1))
			INV_JACOB_F_SQUARE%ENT(2,2) = DOT_PRODUCT(INV_JACOB_F%ENT(2,:), INV_JACOB_F%ENT(:,2))
			
			JACOB_FG%ENT(1,1) = DOT_PRODUCT(INV_JACOB_F_SQUARE%ENT(1,:), JACOB_G%ENT(:,1))
			JACOB_FG%ENT(1,2) = DOT_PRODUCT(INV_JACOB_F_SQUARE%ENT(1,:), JACOB_G%ENT(:,2))
			JACOB_FG%ENT(2,1) = DOT_PRODUCT(INV_JACOB_F_SQUARE%ENT(2,:), JACOB_G%ENT(:,1))
			JACOB_FG%ENT(2,2) = DOT_PRODUCT(INV_JACOB_F_SQUARE%ENT(2,:), JACOB_G%ENT(:,2))
			
			DET_JF = .DETERMINANT.JACOB_F
			WEIGHT(KK) = DET_JF*GSXW(I)*GSYW(J)
! 			PRINT*, 'STIF_LC_INT_IN - HERE0'
			STIF_I(KK) = GET_PHY_BASIS_IN_INT(INV_PHYPT_G, 1, 2, JACOB_FG, 1, 'INV')
! 			CALL GET_ALL_PHY_NURBS_SURFACE_2D(SF1(KK,:), INDX1(:), INV_PHYPT_G, JACOB_FG, 1, 'INV')
! 			PRINT*, 'STIF_LC_INT_IN - HERE1'
			STIF_J(KK) =  GET_PHY_BASIS_IN_INT(DMY_GSPT, 2, 1, JACOB_F, 2)
! 			CALL GET_ALL_PHY_BASIS_IN_INT(SF2(KK,:), INDX2(:), DMY_GSPT, JACOB_F, 2)
! 			PRINT*, 'STIF_LC_INT_IN - HERE2'
		ENDDO
	ENDDO
	
	STIF_INT(1) = DOT_PRODUCT(PRODUCT(RESHAPE((/STIF_I(:)%D10, WEIGHT(:)/), (/NUMGSPT**2, 2/), ORDER=ORDER1), 2), STIF_J(:)%D10)
	STIF_INT(2) = DOT_PRODUCT(PRODUCT(RESHAPE((/STIF_I(:)%D01, WEIGHT(:)/), (/NUMGSPT**2, 2/), ORDER=ORDER1), 2), STIF_J(:)%D01)
	STIF_INT(3) = STIF_INT(3) + SUM(STIF_INT(1:2))
	
! 	PRINT*, 'BUG - HERE3'
	
! 	PRINT*, 'HERE1', STIF_INT(3)
	
	PRINT*, STIF_INT(3), STIF_K(27,8)
	IF (DABS(STIF_K(27,8) - STIF_INT(3)).GT.EPS) THEN
		PRINT*, 'FOUND BUG! - ', 'STIF_K(27,8)', DABS(STIF_K(27,8) - STIF_INT(3))
	ENDIF
	
	
	!----- CHECK STIFFNESS MATRIC -----!
	! (1) STIF_K (28,8), STIF_F(28)

	STIF_INT(:) = 0.D0
	CALL GAULEG(0.25D0, 0.5D0, GSX, GSXW, NUMGSPT)
	CALL GAULEG(0.D0, 0.9D0, GSY, GSYW, NUMGSPT)
	
! 	PRINT*, 'BUG - HERE1'
	
	KK=0
	DO I=1,NUMGSPT
		DO J=1,NUMGSPT
			KK=KK+1
! 			PRINT*, I, J
			GSPT = POINT2D(GSX(I), GSY(J))
			DMY_GSPT = GSPT
			PHYPT_F = GET_PHY_PT(DMY_GSPT,2)
! 			PRINT*, PHYPT_F
			INV_PHYPT_G = GET_REF_PT(PHYPT_F,1)
			
! 			PRINT*, INV_PHYPT_G
			
			JACOB_F = GET_JACOBIAN_MATRIX(DMY_GSPT,2)
			JACOB_G = GET_JACOBIAN_MATRIX(INV_PHYPT_G,1)
			
			INV_JACOB_F = .INVERSE.JACOB_F
			
			INV_JACOB_F_SQUARE%ENT(1,1) = DOT_PRODUCT(INV_JACOB_F%ENT(1,:), INV_JACOB_F%ENT(:,1))
			INV_JACOB_F_SQUARE%ENT(1,2) = DOT_PRODUCT(INV_JACOB_F%ENT(1,:), INV_JACOB_F%ENT(:,2))
			INV_JACOB_F_SQUARE%ENT(2,1) = DOT_PRODUCT(INV_JACOB_F%ENT(2,:), INV_JACOB_F%ENT(:,1))
			INV_JACOB_F_SQUARE%ENT(2,2) = DOT_PRODUCT(INV_JACOB_F%ENT(2,:), INV_JACOB_F%ENT(:,2))
			
			JACOB_FG%ENT(1,1) = DOT_PRODUCT(INV_JACOB_F_SQUARE%ENT(1,:), JACOB_G%ENT(:,1))
			JACOB_FG%ENT(1,2) = DOT_PRODUCT(INV_JACOB_F_SQUARE%ENT(1,:), JACOB_G%ENT(:,2))
			JACOB_FG%ENT(2,1) = DOT_PRODUCT(INV_JACOB_F_SQUARE%ENT(2,:), JACOB_G%ENT(:,1))
			JACOB_FG%ENT(2,2) = DOT_PRODUCT(INV_JACOB_F_SQUARE%ENT(2,:), JACOB_G%ENT(:,2))
			
			DET_JF = .DETERMINANT.JACOB_F
			WEIGHT(KK) = DET_JF*GSXW(I)*GSYW(J)
! 			PRINT*, 'STIF_LC_INT_IN - HERE0'
			STIF_I(KK) = GET_PHY_BASIS_IN_INT(INV_PHYPT_G, 1, 2, JACOB_FG, 1, 'INV')
! 			CALL GET_ALL_PHY_NURBS_SURFACE_2D(SF1(KK,:), INDX1(:), INV_PHYPT_G, JACOB_FG, 1, 'INV')
! 			PRINT*, 'STIF_LC_INT_IN - HERE1'
			STIF_J(KK) =  GET_PHY_BASIS_IN_INT(DMY_GSPT, 3, 1, JACOB_F, 2)
! 			CALL GET_ALL_PHY_BASIS_IN_INT(SF2(KK,:), INDX2(:), DMY_GSPT, JACOB_F, 2)
! 			PRINT*, 'STIF_LC_INT_IN - HERE2'
		ENDDO
	ENDDO
	
! 	PRINT*, 'BUG - HERE2'
	
	STIF_INT(1) = DOT_PRODUCT(PRODUCT(RESHAPE((/STIF_I(:)%D10, WEIGHT(:)/), (/NUMGSPT**2, 2/), ORDER=ORDER1), 2), STIF_J(:)%D10)
	STIF_INT(2) = DOT_PRODUCT(PRODUCT(RESHAPE((/STIF_I(:)%D01, WEIGHT(:)/), (/NUMGSPT**2, 2/), ORDER=ORDER1), 2), STIF_J(:)%D01)
	STIF_INT(3) = STIF_INT(3) + SUM(STIF_INT(1:2))
	
	PRINT*, STIF_INT(3), STIF_K(28,8)
	IF (DABS(STIF_K(28,8) - STIF_INT(3)).GT.EPS) THEN
		PRINT*, 'FOUND BUG! - ', 'STIF_K(28,8)', DABS(STIF_K(28,8) - STIF_INT(3))
	ENDIF
	
	!! SUB_K(14,14)
	
! 	CALL GAULEG(0.D0, 0.25D0, GSX, GSXW, NUMGSPT)
! 	
! 	DO I=1,NUMGSPT
! 		GSPT = POINT2D(GSX(I), 0.D0)
! 		DMY_GSPT = GSPT
! 		JACOB = GET_JACOBIAN_MATRIX(DMY_GSPT,2)
! 		DET_M = .DETERMINANT.JACOB
! ! 		PRINT*, JACOB%ENT(1,1), JACOB%ENT(1,2), JACOB%ENT(2,1), JACOB%ENT(2,2)
! 		BD_WEIGHT(I) = DET_M*GSXW(I)
! ! 		PRINT*, WEIGHT(I)
! 		BD_SF(1,I) =  GET_PHY_BASIS_IN_INT(DMY_GSPT, 1, 0, JACOB, 2)
! ! 					PRINT*, I, EXACT_ON_BD(I)
! 	ENDDO
! 	
! ! 	PRINT*, 'BUG - HERE4'
! 	
! 	STIF_INT(1) = DOT_PRODUCT(PRODUCT(RESHAPE((/BD_SF(1,:)%D00, BD_WEIGHT(:)/), (/NUMGSPT, 2/), ORDER=ORDER1), 2), BD_SF(1,:)%D00)
	
! 	PRINT*, STIF_INT(1)
	
END SUBROUTINE BUGKILLER
	
END MODULE ERRORESTIMATE
