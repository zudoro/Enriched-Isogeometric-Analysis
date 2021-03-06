PROGRAM MAIN

  USE GEOMETRY
  USE PLOT
  USE BOUNDARY
  USE ERRORESTIMATE
	
  implicit integer (i-n)
	implicit real(8) (a-h,o-z)

	REAL*8, ALLOCATABLE :: STIF_K(:,:), DMY_K(:,:), STIF_F(:)
	REAL*8, ALLOCATABLE :: RES_K(:,:), RES_F(:)
  REAL*8 :: ERROR, D, ENRG(4), MAX_NORM(5), L2_NORM(2)
  REAL :: CPTS, CPTE
 	INTEGER :: I, J, II, JJ, TEST_INDX(3,5)
 	INTEGER, ALLOCATABLE :: INDX(:)
	TYPE(POINT2D) :: TSPT, PHYPT
	

	PRINT*, SIZE(TEST_INDX,1), SIZE(TEST_INDX,2), UBOUND(TEST_INDX,1), UBOUND(TEST_INDX,2)
	
	PROBLEM = 2
	EXTRA_KNOTS = (/0,0/)
	
	write(char_problem,fmt='(i1)') PROBLEM
	FILENAME = trim('./data/pv_pro') // char_problem

	OPEN(131, FILE=FILENAME, STATUS='UNKNOWN')
	DO I = 2, 2
		IGA_ORDER = (/I,I/)
		EGM_ORDER = (/I,I/)

		CALL CPU_TIME(CPTS)

		CALL GET_GEO()

		ALLOCATE(STIF_K(DOF,DOF), DMY_K(DOF,DOF), STIF_F(DOF), INDX(DOF), CARRAY(DOF,2))

! 		ALLOCATE(RES_K(DOF,DOF), RES_F(DOF))

! 		PRINT*, 'MAIN - HERE0'

! 		CALL PLOTGM()

! 		STOP
! 		PRINT*, 'MAIN - HERE1'

! 		PHYPT = GET_PHY_PT(POINT2D(0.15D0,0.13D0), 2)
! 		PRINT*, PHYPT
! 		STOP
! 		TSPT = GET_REF_PT(PHYPT,2)
! 		PRINT*,TSPT
! 		STOP

		CALL GEN_KF(STIF_K, STIF_F)

		DMY_K = STIF_K

! 		OPEN(1, FILE = './data/f1')
! 		DO II=1, DOF
! 			WRITE(1,*) STIF_F(II)
! 		ENDDO
! 		CLOSE(1)
! 	! 
! 		OPEN(1, FILE = './data/k1')
! 		DO II=1, DOF
! 			WRITE(1,*) (STIF_K(II,JJ), JJ=1,DOF)
! 		ENDDO
! 		CLOSE(1)
		
! 		CALL BUGKILLER(STIF_K, STIF_F)

		CALL IMPOSEBD(STIF_K,STIF_F)
		
! 		RES_K = STIF_K ; RES_F = STIF_F
		
	! 	OPEN(1, FILE = './data/f2')
	! 	DO I=1, DOF
	! 		WRITE(1,*) F(I)
	! 	ENDDO
	! 	CLOSE(1)
	! 	
	! 	OPEN(1, FILE = './data/k2')
	! 	DO I=1, DOF
	! 		WRITE(1,*) (STIF_K(I,J), J=1,DOF)
	! 	ENDDO
	! 	CLOSE(1)

	! 	RES_K = STIF_K
	! 	DMY_F = F
	! 	
	! 	OPEN(1, FILE = './data/f2')
	! 	DO I=1, DOF
	! 		WRITE(1,*) F(I)
	! 	ENDDO
	! 	CLOSE(1)

		CALL LUDCMP(STIF_K, DOF, DOF, INDX, D)
		CALL LUBKSB(STIF_K, DOF, DOF, INDX, STIF_F)
		
! 		CALL RESIDUALNORM(RES_K, STIF_F, RES_F)

! 		OPEN(1, FILE = './data/sol')
! 		DO II=1, DOF
! 			WRITE(1,*) STIF_F(II)
! 		ENDDO
! 		CLOSE(1)
		
		CALL MAXNORM(MAX_NORM, STIF_F)
! 		PRINT*, 'HERE1'
		CALL ENRGY(ENRG, DMY_K, STIF_F)
! 		PRINT*, 'HERE2'
		CALL L2_NORM_ERROR(L2_NORM, STIF_F)
! 		PRINT*, 'HERE3'
		PRINT*, BASIS_KVEC(1,:)%POLY_ORDER, BASIS_KVEC(2,:)%POLY_ORDER, DOF, MAX_NORM(1), L2_NORM(1), ENRG(4)
		WRITE(131, *) BASIS_KVEC(1,:)%POLY_ORDER, BASIS_KVEC(2,:)%POLY_ORDER, DOF, MAX_NORM(1), L2_NORM(1), ENRG(4), ENRG(2)
		
! 		PRINT*, BS_ORDER(1), DOF, ENRG(4)
! 		WRITE(131, *) DOF, BS_ORDER(1), ENRG(4), ENRG(2)
		
		
		CALL CPU_TIME(CPTE)

		PRINT*, ""
		PRINT*, "ELAPSED CPU TIME : ", CPTE - CPTS
		PRINT*, ""

		DEALLOCATE(STIF_K, DMY_K, STIF_F, INDX, BD_MASK, NDX, CARRAY)

	ENDDO
	CLOSE(131)
END PROGRAM MAIN
