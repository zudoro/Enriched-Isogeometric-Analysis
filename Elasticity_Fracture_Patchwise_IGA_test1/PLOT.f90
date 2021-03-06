MODULE PLOT

	USE PATCH_MAPPING
	USE GEOMETRY
	USE GSQUAD

	implicit integer (i-n)
	implicit real(8) (a-h,o-z)

CONTAINS

SUBROUTINE PLOTGM()
	
	TYPE(RECPATCH) :: IRBOX
	TYPE(TRANSFORM2D) :: GSPT
	TYPE(POINT2D) :: TSPT, PHY_PT, NURBS_TSPT
 	TYPE(FUNCTION_1D) :: TS_BS
	TYPE(FUNCTION_2D) :: DF_NURBS(2)
	TYPE(DIFF_BSPLINES) :: TS_NURBS
	REAL*8 :: NURBS_SUM(2)
	INTEGER :: I, J, II, JJ, KK, NI, NJ, NM, PATCH, IGA_PATCH
	CHARACTER(LEN=7) :: CHAR_PATCH
	CHARACTER(LEN=100) :: PLOT_FILENAME(2)

	DO PATCH = 1, NUM_PATCH
		write(CHAR_PATCH,fmt='(i1)') PATCH
		PLOT_FILENAME(1) = trim('./data/irbox') // CHAR_PATCH
		PLOT_FILENAME(2) = trim('./data/phyirbox') // CHAR_PATCH
		OPEN(1, FILE = PLOT_FILENAME(1), STATUS='UNKNOWN')
		OPEN(2, FILE = PLOT_FILENAME(2), STATUS='UNKNOWN')
		DO JJ=1, NUMIR(PATCH,2)-1
			DO II=1, NUMIR(PATCH,1)-1
				IRBOX%PT1 = POINT2D(IR_GRID(PATCH,1,II), IR_GRID(PATCH,2,JJ))
				IRBOX%PT2 = POINT2D(IR_GRID(PATCH,1,II+1), IR_GRID(PATCH,2,JJ))
				IRBOX%PT3 = POINT2D(IR_GRID(PATCH,1,II+1), IR_GRID(PATCH,2,JJ+1))
				IRBOX%PT4 = POINT2D(IR_GRID(PATCH,1,II), IR_GRID(PATCH,2,JJ+1))
				WRITE(1, *) IRBOX%PT1
				WRITE(1, *) IRBOX%PT2
				WRITE(1, *) IRBOX%PT3
				WRITE(1, *) IRBOX%PT4
				WRITE(1, *) IRBOX%PT1
				WRITE(1,*)
				WRITE(2, *) GET_PHY_PT(IRBOX%PT1, PATCH)
				WRITE(2, *) GET_PHY_PT(IRBOX%PT2, PATCH)
				WRITE(2, *) GET_PHY_PT(IRBOX%PT3, PATCH)
				WRITE(2, *) GET_PHY_PT(IRBOX%PT4, PATCH)
				WRITE(2, *) GET_PHY_PT(IRBOX%PT1, PATCH)
				WRITE(2,*)
			ENDDO
		ENDDO
		CLOSE(1)
		CLOSE(2)
	ENDDO
	
	OPEN(1, FILE = './data/ndx')
	DO I=1, DOF
		WRITE(1,*) NDX(:,I)
	ENDDO
	CLOSE(1)

	OPEN(11, FILE='./data/interface_ndx')
	DO I=1, UBOUND(INTERFACE_NDX,1)
		WRITE(11,*) INTERFACE_NDX(I)%MASTER_PATCH_NDX, INTERFACE_NDX(I)%SLAVE_PATCH_NDX, INTERFACE_NDX(I)%GL_NDX, INTERFACE_NDX(I)%LC_NDX
	ENDDO
	CLOSE(11)

	OPEN(17, FILE='./data/interface_bdndx')
	DO I=1, UBOUND(INTERFACE_BDNDX,1)
		WRITE(17,*) INTERFACE_BDNDX(I)%MASTER_PATCH_NDX, INTERFACE_BDNDX(I)%SLAVE_PATCH_NDX, INTERFACE_BDNDX(I)%GL_NDX, INTERFACE_BDNDX(I)%GL_BDNDX, INTERFACE_BDNDX(I)%LC_NDX
	ENDDO
	CLOSE(17)
	
	OPEN(1, FILE = './data/bdndx')
	DO J = 1, NUM_PATCH
		DO I=1, DR_BDNDX(J,1)%LC_NUM
			WRITE(1,*) J, DR_BDNDX(J,I)%LC_NDX(:), DR_BDNDX(J,I)%LC_NUM, DR_BDNDX(J,I)%GL_NDX
		ENDDO
	ENDDO
	CLOSE(1)
	
	DO PATCH = 1, NUM_PATCH
		write(CHAR_PATCH,fmt='(i1)') PATCH
		PLOT_FILENAME(1) = trim('./data/basis_knot') // CHAR_PATCH
		OPEN(1, FILE = PLOT_FILENAME(1), STATUS='UNKNOWN')
		WRITE(1,*) 'POLY_ORDER : ', BASIS_KVEC(PATCH,1)%POLY_ORDER
		WRITE(1,*) 'LENGTH : ', BASIS_KVEC(PATCH,1)%LENGTH
		DO I=0, BASIS_KVEC(PATCH,1)%LENGTH
			WRITE(1,102) BASIS_KVEC(PATCH,1)%KNOTS(I)
		ENDDO
		WRITE(1,*)
		WRITE(1,*) 'POLY_ORDER : ', BASIS_KVEC(PATCH,2)%POLY_ORDER
		WRITE(1,*) 'LENGTH : ', BASIS_KVEC(PATCH,2)%LENGTH
		DO I=0, BASIS_KVEC(PATCH,2)%LENGTH
			WRITE(1,102) BASIS_KVEC(PATCH,2)%KNOTS(I)
		ENDDO
		CLOSE(1)
	ENDDO

	DO PATCH = 1, NUM_PATCH
		write(CHAR_PATCH,fmt='(i1)') PATCH
		PLOT_FILENAME(1) = trim('./data/ctl') // CHAR_PATCH
		OPEN(11, FILE = PLOT_FILENAME(1), STATUS='UNKNOWN')
		DO I=0, GEO_KVEC(PATCH,2)%LENGTH - GEO_KVEC(PATCH,2)%POLY_ORDER - 1
			DO J=0, GEO_KVEC(PATCH,1)%LENGTH - GEO_KVEC(PATCH,1)%POLY_ORDER - 1
				WRITE(11,*) GEO_CTL(PATCH)%PTS(J,I,0), GEO_CTL(PATCH)%WGTS(J,I,0)
			ENDDO
			WRITE(11,*)
		ENDDO
		DO J=0, GEO_KVEC(PATCH,1)%LENGTH - GEO_KVEC(PATCH,1)%POLY_ORDER - 1
			DO I=0, GEO_KVEC(PATCH,2)%LENGTH - GEO_KVEC(PATCH,2)%POLY_ORDER - 1
				WRITE(11,*) GEO_CTL(PATCH)%PTS(J,I,0), GEO_CTL(PATCH)%WGTS(J,I,0)
			ENDDO
			WRITE(11,*)
		ENDDO
		CLOSE(11)
	ENDDO

	DO PATCH = 1, NUM_PATCH
		write(CHAR_PATCH,fmt='(i1)') PATCH
		PLOT_FILENAME(1) = trim('./data/iga_ctl') // CHAR_PATCH
		OPEN(11, FILE = PLOT_FILENAME(1), STATUS='UNKNOWN')
		DO I=0, NUMBS(PATCH,2)-1
			DO J=0, NUMBS(PATCH,1)-1
				WRITE(11,*) IGA_CTL(PATCH)%PTS(J,I,0), IGA_CTL(PATCH)%WGTS(J,I,0)
			ENDDO
			WRITE(11,*)
		ENDDO
		CLOSE(11)
	ENDDO

	OPEN(1, FILE = './data/ts_ctl')
	DO J = 0, TS_NUMBS - 1
		DO I = 0, TS_NUMBS
			WRITE(1,*) TS_CTL%PTS(I,J,0), TS_CTL%WGTS(I,J,0)
		ENDDO
	ENDDO
	CLOSE(1)

	DO PATCH = 1, NUM_PATCH
		write(CHAR_PATCH,fmt='(i1)') PATCH
		PLOT_FILENAME(1) = trim('./data/bsplinex') // CHAR_PATCH
		OPEN(1, FILE = PLOT_FILENAME(1), STATUS='UNKNOWN')
		DO J=0, NUMBS(PATCH,1)-1
			DO I=1, 601
				TSPT%X = 1.D0*(I-1)/600.D0
				TS_BS = GET_DIFF_BSPLINE(TSPT%X,BASIS_KVEC(PATCH,1),J,2)
				WRITE(1,*) TSPT%X, TS_BS%VAL(:)
			ENDDO
			WRITE(1,*)
		ENDDO
		CLOSE(1)
	ENDDO
	
	DO PATCH = 1, NUM_PATCH
		write(CHAR_PATCH,fmt='(i1)') PATCH
		PLOT_FILENAME(1) = trim('./data/bspliney') // CHAR_PATCH
		OPEN(1, FILE = PLOT_FILENAME(1), STATUS='UNKNOWN')
		DO J=0, NUMBS(PATCH,2)-1
			DO I=1, 601
				TSPT%Y = 1.D0*(I-1)/600.D0
				TS_BS = GET_DIFF_BSPLINE(TSPT%Y,BASIS_KVEC(PATCH,2),J,2)
				WRITE(1,*) TSPT%Y, TS_BS%VAL(:)
			ENDDO
			WRITE(1,*)
		ENDDO
		CLOSE(1)
	ENDDO

	DO PATCH = 1, NUM_PATCH
		write(CHAR_PATCH,fmt='(i1)') PATCH
		PLOT_FILENAME(1) = trim('./data/geometry') // CHAR_PATCH
		OPEN(1, FILE = PLOT_FILENAME(1), STATUS='UNKNOWN')
		DO I=1, 101
			DO J=1, 101
				TSPT%Y = 1.D0*(I-1)/100.D0
				TSPT%X = 1.D0*(J-1)/100.D0
				PHY_PT = GET_PHY_PT(TSPT, PATCH)
				WRITE(1,*) PHY_PT
			ENDDO
			WRITE(1,*) 
		ENDDO
		CLOSE(1)
	ENDDO

	DO PATCH = 1, NUM_PATCH
		write(CHAR_PATCH,fmt='(i1)') PATCH
		PLOT_FILENAME(1) = trim('./data/iga_geometry') // CHAR_PATCH
		OPEN(1, FILE = PLOT_FILENAME(1), STATUS='UNKNOWN')
		DO I=1, 101
			DO J=1, 101
				TSPT%Y = 1.D0*(I-1)/100.D0
				TSPT%X = 1.D0*(J-1)/100.D0
				PHY_PT = GET_POINT_NURVE_SURFACE_2D(TSPT, IGA_KVEC(PATCH,:),IGA_CTL(PATCH))
				WRITE(1,*) PHY_PT
			ENDDO
			WRITE(1,*) 
		ENDDO
		CLOSE(1)
	ENDDO

	OPEN(1, FILE = './data/ts_geometry')
	DO I=1, 101
		DO J=1, 101
			TSPT%Y = 1.D0*(I-1)/100.D0
			TSPT%X = 1.D0*(J-1)/100.D0
			PHY_PT = GET_POINT_NURVE_SURFACE_2D(TSPT, TS_KVEC(:), TS_CTL)
			WRITE(1,*) PHY_PT
		ENDDO
		WRITE(1,*) 
	ENDDO
	CLOSE(1)

! 	PRINT*, 'PLOT - HERE0'

! 	OPEN(1, FILE = './data/FtoG')
! 	DO I = 1, 101
! 		DO J = 1, 101
! 			TSPT%Y = 1.D0*(I-1)/100.D0
! 			TSPT%X = 1.D0*(J-1)/100.D0
! 			PHY_PT = GET_PHY_PT(TSPT, 5)
! 			IGA_PATCH = GET_IGA_PATCH_INDX(PHY_PT)
! ! 			PRINT*, IGA_PATCH, PHY_PT
! 			TSPT = GET_REF_PT(PHY_PT,IGA_PATCH)
! ! 			PRINT*, 'f2f1-',I,J
! 			WRITE(1,*) TSPT
! 		ENDDO
! 		WRITE(1,*) 
! 	ENDDO
! 	CLOSE(1)

! 	OPEN(1, FILE = './data/FtoG1')
! 	DO I = 2, 100
! 		TSPT%Y = 1.D0*(I-1)/100.D0
! 		TSPT%X = 1.D0
! 		PHY_PT = GET_PHY_PT(TSPT, 5)
! ! 		PRINT*, 'TSPT', TSPT
! ! 		PRINT*, 'PHY_PT', PHY_PT
! 		TSPT = GET_REF_PT(PHY_PT, 1)
! 		WRITE(1,*) TSPT
! ! 		PRINT*, 'TSPT', TSPT
! 	ENDDO
! 	CLOSE(1)
! 	
! 	OPEN(1, FILE = './data/FtoG4')
! 	DO I = 2, 100
! 		TSPT%Y = 1.D0*(I-1)/100.D0
! 		TSPT%X = 0.D0
! 		PHY_PT = GET_PHY_PT(TSPT, 5)
! ! 		PRINT*, 'TSPT', TSPT
! ! 		PRINT*, 'PHY_PT', PHY_PT
! 		TSPT = GET_REF_PT(PHY_PT, 4)
! 		WRITE(1,*) TSPT
! ! 		PRINT*, 'TSPT', TSPT
! 	ENDDO
! 	CLOSE(1)
	
	
! 	PRINT*, 'HERE1'

! 	OPEN(1, FILE = './data/GtoF')
! 	DO I = 2, 100
!  		DO J = 2, 100
!  			TSPT%Y = 1.D0*(I-1)/100.D0
! 			TSPT%X = 1.D0*(J-1)/100.D0
! 			PHY_PT = GET_PHY_PT(TSPT, 1)
! 			IF (DSQRT(PHY_PT%X**2 + PHY_PT%Y**2).LE.0.6D0) THEN
! 				TSPT = GET_REF_PT(PHY_PT,2)
! ! 			PRINT*, 'f2f1-',I,J
! 				WRITE(1,*) TSPT
! 			ENDIF
! 		ENDDO
! 		WRITE(1,*) 
! 	ENDDO
! 	CLOSE(1)

! 	PRINT*, 'PLOT - HERE1'

! 	OPEN(1, FILE = './data/test_nurbs_ft')
! 	DO I=1, 101
! 		NURBS_SUM = 0.D0
!  		TSPT%Y = 1.D0*(I-1)/100.D0
! 		TS_NURBS = GET_ALL_DIFF_NURBS_CURVE_2D(TSPT%Y,TEST_KVEC,TEST_CTL,1)
! 		PHY_PT = GET_POINT_NURVE_CURVE_2D(TSPT%Y,TEST_KVEC,TEST_CTL)
! 		WRITE(1,*) PHY_PT, tspt%y, TS_NURBS%N(2,0)
! 		DO J = 0, 2
! 			NURBS_SUM(1) = NURBS_SUM(1) + TS_NURBS%N(J,0)
! 			NURBS_SUM(2) = NURBS_SUM(2) + TS_NURBS%N(J,1)
! 		ENDDO
! ! 		PRINT*, NURBS_SUM
! 	ENDDO
! 	CLOSE(1)

	WRITE(*,*)
	WRITE(*,*) '<<< PLOT DATA AND RECORD INFORMATION : DONE >>>'
	WRITE(*,*)

	102 FORMAT(1000(f20.8,1x))
END SUBROUTINE PLOTGM

END MODULE PLOT
