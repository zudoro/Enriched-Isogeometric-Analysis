PROGRAM MAIN

  USE GEOMETRY
  USE PLOT
  USE BOUNDARY
  USE ERRORESTIMATE
	
  implicit integer (i-n)
	implicit real(8) (a-h,o-z)

	REAL*8, ALLOCATABLE :: STIF_K(:,:), DMY_K(:,:), STIF_F(:)
  REAL*8 :: ERROR, D, ENRG(4), MAX_NORM(5), L2_NORM(2)
  REAL :: CPTS, CPTE
 	INTEGER :: I, J, II, JJ
 	INTEGER, ALLOCATABLE :: INDX(:)
	TYPE(POINT2D) :: TSPT, PHYPT
	
	CHARACTER(LEN=1) :: CHAR_NUM_IRBOX(2), CHAR_EXTRA_KNOTS(2)
	
	PROBLEM = 9
	!-----------------------
	!! When the problem is 3 or 8
! 	LAMBDA = 0.544483737D0
	LAMBDA = 3.D0
	!----------------------
	BCTYPE = 'diric'

	PRINT*, '--------------------------------------------------------'
	PRINT*, 'Elasticity on L-shaped domain by using eXtended Isogeometric Analysis'
	PRINT*, 'Problem : ', PROBLEM
	IF (PROBLEM==4 .OR. PROBLEM==8) THEN
		PRINT*, 'Singular factor : ', LAMBDA
	ENDIF
	PRINT*, 'Boundary Condition : ', BCTYPE
	PRINT*, 'Plane type : ', PLANE_TYPE
	PRINT*, '--------------------------------------------------------'
	
	IF (PROBLEM.LT.10) THEN
		write(char_problem,fmt='(i1)') PROBLEM
	ELSE
		write(char_problem,fmt='(i2)') PROBLEM
	ENDIF
	
	FILENAME = trim('./data/Elasticity_L_shaped_XIGA_k-ref_reg-poly_knot-1_pro') // char_problem // trim('_') // BCTYPE // trim('_') // PLANE_TYPE

	OPEN(131, FILE=FILENAME, STATUS='UNKNOWN')
	DO I = 2, 12
		!-------------------------------------------------------------------------------------------------------------
		!-------------------------------------------------------------------------------------------------------------
		!! Number of sub-rectangles & sub-line intervals of integral limit in the parameter space of the EGM F(xi,eta)
		NUM_IRBOX = (/2,2/)
		NUM_LN = 2
		!! Default number of gauss points
		NUMGSPT = 18
		!! Number of gauss points on the sub-rectangles & sub-line intervals in the parameter space of the EGM F(xi,eta)
		XIGA_NUMGSPT = NUMGSPT
		!! Number of gauss points for estimating the relative maximum norm error
		MX_GSPT = 10 
		!! Number of knot insertation for h-refinement in IGA
		IGA_KNOTS = (/1,1/)
		!! Number of knot insertation for h-refinement along xi direction in Enrichment
		EGM_KNOTS = (/0,0/)
		!! The order of NURBS & B-spline functions for degree elevation which is p-refinement in IGA
		IGA_ORDER = (/I,I/)
		!! Regularity of B-Spline basis functions corresponding to knots inserted in IGA
		IGA_REGULARITY = (/IGA_ORDER(1)-1, IGA_ORDER(2)-1/)
		!! Degree of B-Spline along eta direction in exotic geometrical mapping construction
		IF (PROBLEM==8) THEN
			EGM_ETA_ORDER = INT(LAMBDA)
		ELSEIF (PROBLEM==4) THEN
			EGM_ETA_ORDER = 5
		ELSE
			EGM_ETA_ORDER = 3
		ENDIF
		!! Degree of B-Spline basis function in EGM
		EGM_ORDER = (/I,I/)
		
		!-------------------------------------------------------------------------------------------------------------
		!-------------------------------------------------------------------------------------------------------------
		
		CALL CPU_TIME(CPTS)
		
		!! Construct NURBS & exotic geometrical mappings and set all of indices
		CALL GET_GEO()
		
		ALLOCATE(STIF_K(2*DOF,2*DOF), DMY_K(2*DOF,2*DOF), STIF_F(2*DOF), INDX(2*DOF), CARRAY(DOF,2))
		ALLOCATE(GSX(NUMGSPT), GSXW(NUMGSPT), GSY(NUMGSPT), GSYW(NUMGSPT))
		ALLOCATE(MX_GSX(MX_GSPT), MX_GSXW(MX_GSPT), MX_GSY(MX_GSPT), MX_GSYW(MX_GSPT))
		ALLOCATE(XIGA_GSX(XIGA_NUMGSPT), XIGA_GSY(XIGA_NUMGSPT), XIGA_GSXW(XIGA_NUMGSPT), XIGA_GSYW(XIGA_NUMGSPT))
		
		!! Save data
		CALL PLOTGM()

		!! Assemble stiffness matrix and load vector
		CALL GEN_KF(STIF_K, STIF_F)

		DMY_K = STIF_K

! 		OPEN(1, FILE = './data/f1')
! 		DO II=1, 2*DOF
! 			WRITE(1,*) STIF_F(II)
! 		ENDDO
! 		CLOSE(1)
! 	! 
! 		OPEN(1, FILE = './data/k1_pro8_p2')
! 		DO II=1, 2*DOF
! 			WRITE(1,*) (STIF_K(II,JJ), JJ=1, 2*DOF)
! 		ENDDO
! 		CLOSE(1)
		
		!! Impose boundary condtions
		CALL IMPOSEBD(STIF_K,STIF_F)

	! 	OPEN(1, FILE = './data/f2')
	! 	DO I=1, 2*DOF
	! 		WRITE(1,*) F(I)
	! 	ENDDO
	! 	CLOSE(1)
	! 	
! 		OPEN(1, FILE = './data/k2')
! 		DO II=1, 2*DOF
! 			WRITE(1,*) (STIF_K(II,JJ), JJ=1, 2*DOF)
! 		ENDDO
! 		CLOSE(1)

	! 	RES_K = STIF_K
	! 	DMY_F = F
	! 	
	! 	OPEN(1, FILE = './data/f2')
	! 	DO I=1, 2*DOF
	! 		WRITE(1,*) F(I)
	! 	ENDDO
	! 	CLOSE(1)
		
		!! Solve matrix system
		CALL LUDCMP(STIF_K, 2*DOF, 2*DOF, INDX, D)
		CALL LUBKSB(STIF_K, 2*DOF, 2*DOF, INDX, STIF_F)
		
		!! Compute residual norm
! 		CALL RESIDUALNORM(RES_K, F, DMY_F)

! 		OPEN(1, FILE = './data/sol')
! 		DO II=1, 2*DOF
! 			WRITE(1,*) STIF_F(II)
! 		ENDDO
! 		CLOSE(1)
		
		!! Compute rel. max. norm error
		CALL MAXNORM(MAX_NORM, STIF_F)
		!! Compute rel. eng. norm error
		CALL ENRGY(ENRG, DMY_K, STIF_F)
		!! Compue rel. L2 norm error in singular zone
		CALL L2_NORM_ERROR(L2_NORM, STIF_F)

		PRINT*, '----------------------------------------------------------------------------------------------------------------------------------'
		PRINT*, IGA_ORDER(1), IGA_KNOTS(1), EGM_ORDER(1), NUM_IRBOX(1), 2*DOF-2*BD_DOF, MAX_NORM(:), L2_NORM(:), ENRG(4), ENRG(2)
		PRINT*, '----------------------------------------------------------------------------------------------------------------------------------'
		WRITE(131, *) IGA_ORDER(1), IGA_KNOTS(1), EGM_ORDER(1), NUM_IRBOX(1), 2*DOF-2*BD_DOF, MAX_NORM(:), L2_NORM(:), ENRG(4), ENRG(2)
		
! 		PRINT*, BS_ORDER(1), DOF, ENRG(4)
! 		WRITE(131, *) DOF, BS_ORDER(1), ENRG(4), ENRG(2)
		
		CALL CPU_TIME(CPTE)

		PRINT*, ""
		PRINT*, "ELAPSED CPU TIME : ", CPTE - CPTS
		PRINT*, ""

		DEALLOCATE(STIF_K, DMY_K, STIF_F, INDX, BD_MASK, NDX, DMY_NDX, INTERFACE_NDX, INTERFACE_BDNDX, CARRAY)
		DEALLOCATE(GSX, GSY, GSXW, GSYW)
		DEALLOCATE(MX_GSX, MX_GSY, MX_GSXW, MX_GSYW)
		DEALLOCATE(XIGA_GSX, XIGA_GSY, XIGA_GSXW, XIGA_GSYW)
		
	ENDDO
	CLOSE(131)
END PROGRAM MAIN
