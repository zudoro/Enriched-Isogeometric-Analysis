MODULE GEOMETRY

	USE PATCH_MAPPING

	IMPLICIT NONE
	
! 	IMPLICIT INTEGER (I-N)
! 	IMPLICIT REAL(8) (A-H,O-Z)

CONTAINS

SUBROUTINE GET_GEO()
	
	TYPE(KNOT_VECTOR) :: OLD_BASIS_KVEC(2)
	INTEGER :: I, J, II, JJ, K, KK, PATCH, IGA_PATCH, EGM_PATCH, DIR
	INTEGER :: BASIS_POLY_ORDER, OLD_BASIS_POLY_ORDER, BASIS_NUM_KNOTS, OLD_BASIS_NUM_KNOTS, EGMAP_NUM_KNOTS
	INTEGER :: BASIS_MULTIPLICITIES(MAX_LENGTH), OLD_BASIS_MULTIPLICITIES(MAX_LENGTH), EGMAP_POLY_ORDER, EGMAP_MULTIPLICITIES(MAX_LENGTH)
	REAL(8) :: BASIS_KNOTS(MAX_LENGTH), OLD_BASIS_KNOTS(MAX_LENGTH), NEW_KNOTS(0:MAX_LENGTH), EGMAP_KNOTS(MAX_LENGTH)
	CHARACTER(LEN=1) :: AXIS
	
! IGA - L-shaped domain with three patches
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	DO PATCH=1, NUM_IGA_PATCH
		GEO_KVEC(PATCH,:)%POLY_ORDER = (/2,2/)
		GEO_CTL(PATCH)%D=2
		
		GEO_KVEC(PATCH,1)%LENGTH = 5
		GEO_KVEC(PATCH,2)%LENGTH = 5

		GEO_KVEC(PATCH,1)%KNOTS(0:GEO_KVEC(PATCH,1)%LENGTH) = (/0.D0, 0.D0, 0.D0, 1.D0, 1.D0, 1.D0/)
		GEO_KVEC(PATCH,2)%KNOTS(0:GEO_KVEC(PATCH,2)%LENGTH) = (/0.D0, 0.D0, 0.D0, 1.D0, 1.D0, 1.D0/)
	ENDDO

! SET CONTROL POINTS AND WEIGTH
	
	!! IGA PATCH #1
	GEO_CTL(1)%PTS(0,0,0) = POINT2D(0.D0,0.D0)
	GEO_CTL(1)%PTS(1,0,0) = POINT2D(0.5D0,0.D0)
	GEO_CTL(1)%PTS(2,0,0) = POINT2D(1.D0,0.D0)
	GEO_CTL(1)%PTS(0,1,0) = POINT2D(0.D0,0.5D0)
	GEO_CTL(1)%PTS(1,1,0) = POINT2D(0.5D0,0.5D0)
	GEO_CTL(1)%PTS(2,1,0) = POINT2D(1.D0,0.5D0)
	GEO_CTL(1)%PTS(0,2,0) = POINT2D(0.D0,1.D0)
	GEO_CTL(1)%PTS(1,2,0) = POINT2D(0.5D0,1.D0)
	GEO_CTL(1)%PTS(2,2,0) = POINT2D(1.D0,1.D0)
	
	GEO_CTL(1)%WGTS(0:2,0:2,0) = 1.D0
	
	!! IGA PATCH #2
	GEO_CTL(2)%PTS(0,0,0) = POINT2D(-1.D0,0.D0)
	GEO_CTL(2)%PTS(1,0,0) = POINT2D(-0.5D0,0.D0)
	GEO_CTL(2)%PTS(2,0,0) = POINT2D(0.D0,0.D0)
	GEO_CTL(2)%PTS(0,1,0) = POINT2D(-1.D0,0.5D0)
	GEO_CTL(2)%PTS(1,1,0) = POINT2D(-0.5D0,0.5D0)
	GEO_CTL(2)%PTS(2,1,0) = POINT2D(0.D0,0.5D0)
	GEO_CTL(2)%PTS(0,2,0) = POINT2D(-1.D0,1.D0)
	GEO_CTL(2)%PTS(1,2,0) = POINT2D(-0.5D0,1.D0)
	GEO_CTL(2)%PTS(2,2,0) = POINT2D(0.D0,1.D0)

	GEO_CTL(2)%WGTS(0:2,0:2,0) = 1.D0
	
	!! IGA PATCH #3
	GEO_CTL(3)%PTS(0,0,0) = POINT2D(-1.D0,-1.D0)
	GEO_CTL(3)%PTS(1,0,0) = POINT2D(-0.5D0,-1.D0)
	GEO_CTL(3)%PTS(2,0,0) = POINT2D(0.D0,-1.D0)
	GEO_CTL(3)%PTS(0,1,0) = POINT2D(-1.D0,-0.5D0)
	GEO_CTL(3)%PTS(1,1,0) = POINT2D(-0.5D0,-0.5D0)
	GEO_CTL(3)%PTS(2,1,0) = POINT2D(0.D0,-0.5D0)
	GEO_CTL(3)%PTS(0,2,0) = POINT2D(-1.D0,0.D0)
	GEO_CTL(3)%PTS(1,2,0) = POINT2D(-0.5D0,0.D0)
	GEO_CTL(3)%PTS(2,2,0) = POINT2D(0.D0,0.D0)
	
	GEO_CTL(3)%WGTS(0:2,0:2,0) = 1.D0

	!! Rotate the IGA patches
	DO PATCH = 1, NUM_IGA_PATCH
		DO I = 0, 2
			DO J = 0, 2
				GEO_CTL(PATCH)%PTS(I,J,0) = ROTATION(GEO_CTL(PATCH)%PTS(I,J,0), -135.D0*DEGREE)
			ENDDO
		ENDDO
	ENDDO
	
	DO I = 1, NUM_IGA_PATCH
		IGA_CTL(I) = GEO_CTL(I)
	ENDDO
	
	IGA_KVEC(1:NUM_IGA_PATCH,:) = GEO_KVEC(1:NUM_IGA_PATCH,:)

!-----------------------------------------------------------------------------------------------------------
! Elevate degree of B-Spline function
	DO PATCH = 1, NUM_IGA_PATCH
		IF (IGA_ORDER(1).GT.GEO_KVEC(PATCH,1)%POLY_ORDER) THEN
			CALL ELEVATE_DEGREE(IGA_KVEC(PATCH,:), IGA_CTL(PATCH), IGA_ORDER(1)-GEO_KVEC(PATCH,1)%POLY_ORDER, 'X')
		ENDIF
		IF (IGA_ORDER(2).GT.GEO_KVEC(PATCH,2)%POLY_ORDER) THEN
			CALL ELEVATE_DEGREE(IGA_KVEC(PATCH,:), IGA_CTL(PATCH), IGA_ORDER(2)-GEO_KVEC(PATCH,2)%POLY_ORDER, 'Y')
		ENDIF
	ENDDO
!-----------------------------------------------------------------------------------------------------------

!-----------------------------------------------------------------------------------------------------------
! Refine knot vector inserting new knots with multiplicities are greater than 1
	
	DO PATCH = 1, NUM_IGA_PATCH
		NEW_KNOTS(:) = -1.D0
		OLD_BASIS_KVEC(:) = IGA_KVEC(PATCH,:)
		DO DIR = 1, 2
	! 		PRINT*, 'DIR', DIR
			IF (IGA_KNOTS(DIR).GT.0) THEN
				IGA_KVEC(PATCH,DIR) = UNIFORM_KNOT_INSERTION(IGA_KVEC(PATCH,DIR), IGA_KNOTS(DIR), IGA_REGULARITY(DIR))
				CALL KNOT_TO_ARRAY(OLD_BASIS_KVEC(DIR), OLD_BASIS_POLY_ORDER, OLD_BASIS_NUM_KNOTS, OLD_BASIS_KNOTS, OLD_BASIS_MULTIPLICITIES)
				CALL KNOT_TO_ARRAY(IGA_KVEC(PATCH,DIR), BASIS_POLY_ORDER, BASIS_NUM_KNOTS, BASIS_KNOTS, BASIS_MULTIPLICITIES)
				
				JJ = 1
				K = -1
				DO II = 1, BASIS_NUM_KNOTS
					IF (DABS(BASIS_KNOTS(II) - OLD_BASIS_KNOTS(JJ)).LE.EPS .AND. BASIS_MULTIPLICITIES(II).EQ.OLD_BASIS_MULTIPLICITIES(JJ)) THEN
						JJ = JJ + 1
					ELSEIF (BASIS_KNOTS(II).LT.OLD_BASIS_KNOTS(JJ)) THEN
						DO I = 1, BASIS_MULTIPLICITIES(II)
							K = K + 1
							NEW_KNOTS(K) = BASIS_KNOTS(II)
						ENDDO
					ELSEIF (DABS(BASIS_KNOTS(II) - OLD_BASIS_KNOTS(JJ)).LE.EPS .AND. BASIS_MULTIPLICITIES(II).NE.OLD_BASIS_MULTIPLICITIES(JJ)) THEN
						DO I = 1, BASIS_MULTIPLICITIES(II) - OLD_BASIS_MULTIPLICITIES(JJ)
							K = K + 1
							NEW_KNOTS(K) = BASIS_KNOTS(II)
						ENDDO
					ENDIF
				ENDDO
				IF (DIR==1) THEN
					AXIS = 'X'
				ELSEIF (DIR==2) THEN
					AXIS = 'Y'
				ENDIF
				CALL REFINE_KNOT(OLD_BASIS_KVEC(:), IGA_CTL(PATCH), NEW_KNOTS(0:K), K, AXIS)
			ENDIF	
		ENDDO
		NUMBS(PATCH,:) = (/IGA_KVEC(PATCH,1)%LENGTH-IGA_KVEC(PATCH,1)%POLY_ORDER,IGA_KVEC(PATCH,2)%LENGTH-IGA_KVEC(PATCH,2)%POLY_ORDER/)
	ENDDO

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! EGM - L-shaped domain with arbitrary order of B-spline along eta-direction
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	GEO_KVEC(4,1)%POLY_ORDER = 2
	GEO_KVEC(4,2)%POLY_ORDER = EGM_ETA_ORDER

	GEO_KVEC(4,1)%LENGTH = 9
	GEO_KVEC(4,2)%LENGTH = 3*GEO_KVEC(4,2)%POLY_ORDER + 1

	GEO_KVEC(4,1)%KNOTS(0:GEO_KVEC(4,1)%LENGTH) = (/0.D0, 0.D0, 0.D0, 0.4d0, 0.4d0, 0.6d0, 0.6d0, 1.D0, 1.D0, 1.D0/)
	
	DO I = 0, GEO_KVEC(4,2)%POLY_ORDER
		GEO_KVEC(4,2)%KNOTS(I) = 0.D0
	ENDDO
	DO I = GEO_KVEC(4,2)%POLY_ORDER + 1, 2*GEO_KVEC(4,2)%POLY_ORDER
		GEO_KVEC(4,2)%KNOTS(I) = 0.5D0
	ENDDO
	DO I = 2*GEO_KVEC(4,2)%POLY_ORDER + 1, 3*GEO_KVEC(4,2)%POLY_ORDER + 1
		GEO_KVEC(4,2)%KNOTS(I) = 1.D0
	ENDDO
	
! SET CONTROL POINTS AND WEIGTH
	GEO_CTL(4)%D=2
	
	GEO_CTL(4)%PTS(0:6,0:GEO_KVEC(4,2)%POLY_ORDER-1,0) = POINT2D(0.D0,0.D0)

	GEO_CTL(4)%PTS(0,GEO_KVEC(4,2)%LENGTH - GEO_KVEC(4,2)%POLY_ORDER - 1,0) = POINT2D(0.D0,					-INNER_RADIUS)
	GEO_CTL(4)%PTS(1,GEO_KVEC(4,2)%LENGTH - GEO_KVEC(4,2)%POLY_ORDER - 1,0) = POINT2D(-INNER_RADIUS,-INNER_RADIUS)
	GEO_CTL(4)%PTS(2,GEO_KVEC(4,2)%LENGTH - GEO_KVEC(4,2)%POLY_ORDER - 1,0) = POINT2D(-INNER_RADIUS, 0.D0)
	GEO_CTL(4)%PTS(3,GEO_KVEC(4,2)%LENGTH - GEO_KVEC(4,2)%POLY_ORDER - 1,0) = POINT2D(-INNER_RADIUS, INNER_RADIUS)
	GEO_CTL(4)%PTS(4,GEO_KVEC(4,2)%LENGTH - GEO_KVEC(4,2)%POLY_ORDER - 1,0) = POINT2D(0.D0,					 INNER_RADIUS)
	GEO_CTL(4)%PTS(5,GEO_KVEC(4,2)%LENGTH - GEO_KVEC(4,2)%POLY_ORDER - 1,0) = POINT2D(INNER_RADIUS,	 INNER_RADIUS)
	GEO_CTL(4)%PTS(6,GEO_KVEC(4,2)%LENGTH - GEO_KVEC(4,2)%POLY_ORDER - 1,0) = POINT2D(INNER_RADIUS,	 0.D0)

	DO I = 0, 6
		GEO_CTL(4)%PTS(I,GEO_KVEC(4,2)%POLY_ORDER,0) = ((INNER_RADIUS - INNER_LAYER)/INNER_RADIUS)*&
																										GEO_CTL(4)%PTS(I,GEO_KVEC(4,2)%LENGTH - GEO_KVEC(4,2)%POLY_ORDER - 1,0)
		DO J = GEO_KVEC(4,2)%POLY_ORDER + 1, GEO_KVEC(4,2)%LENGTH - GEO_KVEC(4,2)%POLY_ORDER - 2
			IF (GEO_CTL(4)%PTS(I,GEO_KVEC(4,2)%LENGTH - GEO_KVEC(4,2)%POLY_ORDER - 1,0)%X<0.D0) THEN
				GEO_CTL(4)%PTS(I,J,0)%X = GEO_CTL(4)%PTS(I,GEO_KVEC(4,2)%POLY_ORDER,0)%X - 1.D0*(J-GEO_KVEC(4,2)%POLY_ORDER)*&
																	DABS(GEO_CTL(4)%PTS(I,GEO_KVEC(4,2)%LENGTH - GEO_KVEC(4,2)%POLY_ORDER - 1,0)%X - &
																			 GEO_CTL(4)%PTS(I,GEO_KVEC(4,2)%POLY_ORDER,0)%X)/ &
																	(1.D0*(GEO_KVEC(4,2)%LENGTH - 2*GEO_KVEC(4,2)%POLY_ORDER - 1))
			ELSE
				GEO_CTL(4)%PTS(I,J,0)%X = GEO_CTL(4)%PTS(I,GEO_KVEC(4,2)%POLY_ORDER,0)%X + 1.D0*(J-GEO_KVEC(4,2)%POLY_ORDER)*&
																	DABS(GEO_CTL(4)%PTS(I,GEO_KVEC(4,2)%LENGTH - GEO_KVEC(4,2)%POLY_ORDER - 1,0)%X - &
																			 GEO_CTL(4)%PTS(I,GEO_KVEC(4,2)%POLY_ORDER,0)%X)/ &
																	(1.D0*(GEO_KVEC(4,2)%LENGTH - 2*GEO_KVEC(4,2)%POLY_ORDER - 1))
			ENDIF
			IF (GEO_CTL(4)%PTS(I,GEO_KVEC(4,2)%LENGTH - GEO_KVEC(4,2)%POLY_ORDER - 1,0)%Y<0.D0) THEN
				GEO_CTL(4)%PTS(I,J,0)%Y = GEO_CTL(4)%PTS(I,GEO_KVEC(4,2)%POLY_ORDER,0)%Y - 1.D0*(J-GEO_KVEC(4,2)%POLY_ORDER)*&
																	DABS(GEO_CTL(4)%PTS(I,GEO_KVEC(4,2)%LENGTH - GEO_KVEC(4,2)%POLY_ORDER - 1,0)%Y - &
																			 GEO_CTL(4)%PTS(I,GEO_KVEC(4,2)%POLY_ORDER,0)%Y)/ &
																	(1.D0*(GEO_KVEC(4,2)%LENGTH - 2*GEO_KVEC(4,2)%POLY_ORDER - 1))
			ELSE
				GEO_CTL(4)%PTS(I,J,0)%Y = GEO_CTL(4)%PTS(I,GEO_KVEC(4,2)%POLY_ORDER,0)%Y + 1.D0*(J-GEO_KVEC(4,2)%POLY_ORDER)*&
																	DABS(GEO_CTL(4)%PTS(I,GEO_KVEC(4,2)%LENGTH - GEO_KVEC(4,2)%POLY_ORDER - 1,0)%Y - &
																			 GEO_CTL(4)%PTS(I,GEO_KVEC(4,2)%POLY_ORDER,0)%Y)/ &
																	(1.D0*(GEO_KVEC(4,2)%LENGTH - 2*GEO_KVEC(4,2)%POLY_ORDER - 1))
			ENDIF
		ENDDO
	ENDDO
		
	DO I=0, GEO_KVEC(4,2)%LENGTH - GEO_KVEC(4,2)%POLY_ORDER - 1
		GEO_CTL(4)%WGTS(0:6,I,0) = (/1.D0, DCOS(45.D0*DEGREE), 1.D0, DCOS(45.D0*DEGREE), 1.D0, DCOS(45.D0*DEGREE), 1.D0/)
	ENDDO
	
	!----------------------------------------------------------------------------------------------------------------------------!

	!! Rotate the EGM patches
	DO PATCH = NUM_IGA_PATCH + 1, NUM_PATCH
		DO I = 0, 6
			DO J = 0, GEO_KVEC(4,2)%LENGTH - GEO_KVEC(4,2)%POLY_ORDER - 1
				GEO_CTL(PATCH)%PTS(I,J,0) = ROTATION(GEO_CTL(PATCH)%PTS(I,J,0), -135.D0*DEGREE)
			ENDDO
		ENDDO
	ENDDO
	
	!!----------------------------------------------------------------------------------------------------------------------------------------!!
	
	!!	Construct B-Spline basis functions based on knot vectors corresponding to exotic geometrical mappings
	EGM_PATCH = 4
	CALL KNOT_TO_ARRAY(GEO_KVEC(EGM_PATCH,2), EGMAP_POLY_ORDER, EGMAP_NUM_KNOTS, EGMAP_KNOTS, EGMAP_MULTIPLICITIES)
	
	EGM_KVEC(1,1)%POLY_ORDER = 2
	EGM_KVEC(1,2)%POLY_ORDER = 2
	
	EGM_KVEC(1,1)%LENGTH = 9
	EGM_KVEC(1,2)%LENGTH = 2*(EGM_KVEC(1,2)%POLY_ORDER + 1) + EGM_KVEC(1,2)%POLY_ORDER*(EGMAP_NUM_KNOTS - 2) - 1
	
	EGM_KVEC(1,1)%KNOTS(0:EGM_KVEC(1,1)%LENGTH) = (/0.D0, 0.D0, 0.D0, 0.4d0, 0.4d0, 0.6d0, 0.6d0, 1.D0, 1.D0, 1.D0/)
	
	!! {0, 0, 0, ...
	DO I = 0, EGM_KVEC(1,2)%POLY_ORDER
		EGM_KVEC(1,2)%KNOTS(I) = 0.D0
	ENDDO
	
	!! ..., knot1, knot2, knot3, ...
	K = 0
	DO J = 1, EGMAP_NUM_KNOTS
		IF (EGMAP_KNOTS(J)>0.D0 .AND. EGMAP_KNOTS(J)<1.D0) THEN
			K = K + 1
			DO I = K*EGM_KVEC(1,2)%POLY_ORDER + 1, (K+1)*EGM_KVEC(1,2)%POLY_ORDER
				EGM_KVEC(1,2)%KNOTS(I) = EGMAP_KNOTS(J)
			ENDDO
		ENDIF
	ENDDO
	
	!! ..., 1, 1, 1, ...}
	DO I = EGM_KVEC(1,2)%LENGTH - EGM_KVEC(1,2)%POLY_ORDER, EGM_KVEC(1,2)%LENGTH
		EGM_KVEC(1,2)%KNOTS(I) = 1.D0
	ENDDO
	
	!! p-refinement
	DO PATCH = 1, NUM_EGM_PATCH
		IF (EGM_ORDER(1).GT.EGM_KVEC(PATCH,1)%POLY_ORDER) THEN
			DO I=1, EGM_ORDER(1) - EGM_KVEC(PATCH,1)%POLY_ORDER
				EGM_KVEC(PATCH,1) = DEGREE_ELEVATION(EGM_KVEC(PATCH,1))
			ENDDO
		ENDIF
		IF (EGM_ORDER(2).GT.EGM_KVEC(PATCH,2)%POLY_ORDER) THEN
			DO I=1, EGM_ORDER(2) - EGM_KVEC(PATCH,2)%POLY_ORDER
				EGM_KVEC(PATCH,2) = DEGREE_ELEVATION(EGM_KVEC(PATCH,2))
			ENDDO
		ENDIF
		!! h-refinement
		IF (EGM_KNOTS(1)>0) THEN
			EGM_KVEC(PATCH,1) = UNIFORM_KNOT_INSERTION(EGM_KVEC(PATCH,1),EGM_KNOTS(1))
		ENDIF
		IF (EGM_KNOTS(2)>0) THEN
			EGM_KVEC(PATCH,2) = UNIFORM_KNOT_INSERTION(EGM_KVEC(PATCH,2),EGM_KNOTS(2))
		ENDIF
		NUMBS(NUM_IGA_PATCH + PATCH,:) = (/EGM_KVEC(PATCH,1)%LENGTH-EGM_KVEC(PATCH,1)%POLY_ORDER, EGM_KVEC(PATCH,2)%LENGTH-EGM_KVEC(PATCH,2)%POLY_ORDER/)
	ENDDO
	
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	WRITE(*,*)
	WRITE(*,*) '<<< SET GEOMETRIC KNOT, CONTROL POINTS, AND WEIGHT : DONE >>>'
	WRITE(*,*)
	
	DO I = 1, NUM_IGA_PATCH
		BASIS_KVEC(I,:) = IGA_KVEC(I,:)
	ENDDO
	DO I = 1, NUM_EGM_PATCH
		BASIS_KVEC(NUM_IGA_PATCH + I,:) = EGM_KVEC(I,:)
	ENDDO

	DO I = 1, NUM_PATCH
		FULL_LOCAL_DOF(I) = NUMBS(I,1)*NUMBS(I,2)
	ENDDO

! Local Index
	ALLOCATE(INTERFACE_NDX(NUMBS(1,2) + NUMBS(2,1) - 2))
	
	INTERFACE_NDX(:)%GL_NDX = -1
	DO I = 1, 8
		INTERFACE_NDX(:)%LC_NDX(I) = -1
	ENDDO
	INTERFACE_NDX(:)%MASTER_PATCH_NDX = -1
	INTERFACE_NDX(:)%EGM_PATCH_NDX = -1
	INTERFACE_NDX(:)%SLAVE_PATCH_NDX(1) = -1
	INTERFACE_NDX(:)%SLAVE_PATCH_NDX(2) = -1
	INTERFACE_NDX(:)%SLAVE_PATCH_NDX(3) = -1
	
	LOCAL_DOF(1) = FULL_LOCAL_DOF(1) - 1
	LOCAL_DOF(2) = FULL_LOCAL_DOF(2) - NUMBS(2,2)
	LOCAL_DOF(3) = FULL_LOCAL_DOF(3) - NUMBS(3,1)
	LOCAL_DOF(4) = FULL_LOCAL_DOF(4) - (BASIS_KVEC(4,2)%POLY_ORDER + 1)*NUMBS(4,1)
! 	LOCAL_DOF(4) = FULL_LOCAL_DOF(4) - NUMBS(4,1)
	
	DOF = SUM(LOCAL_DOF(:))

! TEMPORIARY GLOBAL INDEX
	ALLOCATE(DMY_NDX(2, SUM(FULL_LOCAL_DOF(:))))
	ALLOCATE(NDX(2,DOF))

	K = 0
	DO II = 1, NUM_PATCH
		DO I = 1, NUMBS(II,1)*NUMBS(II,2)
			K = K + 1
			DMY_NDX(1,K)=MOD(I+(NUMBS(II,1)-1), NUMBS(II,1))
			DMY_NDX(2,K)=MOD(INT((I-1)/NUMBS(II,1)) + NUMBS(II,2), NUMBS(II,2))
		ENDDO
	ENDDO
	
	!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	
! Index on Interface
	DO I = 1, NUMBS(1,2) - 1
		INTERFACE_NDX(I)%GL_NDX = (I)*NUMBS(1,1)
		INTERFACE_NDX(I)%LC_NDX = (/DMY_NDX(:,INTERFACE_NDX(I)%GL_NDX + 1), DMY_NDX(:,FULL_LOCAL_DOF(1) + (I+1)*NUMBS(2,1)), -1, -1, -1, -1/)
		INTERFACE_NDX(I)%MASTER_PATCH_NDX = 1
		INTERFACE_NDX(I)%EGM_PATCH_NDX = 1
		INTERFACE_NDX(I)%SLAVE_PATCH_NDX(1) = 2
		INTERFACE_NDX(I)%SLAVE_PATCH_NDX(2) = -1
		INTERFACE_NDX(I)%SLAVE_PATCH_NDX(3) = -1
	ENDDO

	DO I = 1, NUMBS(2,1) - 1
		INTERFACE_NDX(NUMBS(1,2) - 1 + I)%GL_NDX = LOCAL_DOF(1) + I
		INTERFACE_NDX(NUMBS(1,2) - 1 + I)%LC_NDX = (/DMY_NDX(:,FULL_LOCAL_DOF(1) + I), DMY_NDX(:,SUM(FULL_LOCAL_DOF(1:3)) - NUMBS(3,1) + I), -1, -1, -1, -1/)
		INTERFACE_NDX(NUMBS(1,2) - 1 + I)%MASTER_PATCH_NDX = 2
		INTERFACE_NDX(NUMBS(1,2) - 1 + I)%EGM_PATCH_NDX = 1
		INTERFACE_NDX(NUMBS(1,2) - 1 + I)%SLAVE_PATCH_NDX(1) = 3
		INTERFACE_NDX(NUMBS(1,2) - 1 + I)%SLAVE_PATCH_NDX(2) = -1
		INTERFACE_NDX(NUMBS(1,2) - 1 + I)%SLAVE_PATCH_NDX(3) = -1
	ENDDO

	!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	
	! Actual Global Index
	K = 0
	DO I=1, FULL_LOCAL_DOF(1)
		IF (DMY_NDX(1, I)==0 .AND. DMY_NDX(2, I)==0) THEN
		ELSE
			K = K + 1
			NDX(1, K) = DMY_NDX(1, I)
			NDX(2, K) = DMY_NDX(2, I)
		ENDIF
	ENDDO
	
	IF (K.NE.LOCAL_DOF(1)) THEN
		PRINT*, 'ERROR - LOCAL_DOF(1) : ', 'LOCAL_DOF(1) = ', LOCAL_DOF(1), 'K = ', K
	ENDIF
	
	K = 0
	DO I=1, FULL_LOCAL_DOF(2)
		IF (DMY_NDX(1, FULL_LOCAL_DOF(1) + I).EQ.(NUMBS(2,1)-1)) THEN
		ELSE
			K = K + 1
			NDX(1,LOCAL_DOF(1) + K) = DMY_NDX(1,FULL_LOCAL_DOF(1)+I)
			NDX(2,LOCAL_DOF(1) + K) = DMY_NDX(2,FULL_LOCAL_DOF(1)+I)
		ENDIF
	ENDDO

	IF (K.NE.LOCAL_DOF(2)) THEN
		PRINT*, 'ERROR - LOCAL_DOF(2) : ', 'LOCAL_DOF(2) = ', LOCAL_DOF(2), 'K = ', K
	ENDIF
	
	K = 0
	DO I=1, FULL_LOCAL_DOF(3)
		IF (DMY_NDX(2, SUM(FULL_LOCAL_DOF(1:2)) + I).EQ.(NUMBS(3,2)-1)) THEN
		ELSE
			K = K + 1
			NDX(1,SUM(LOCAL_DOF(1:2)) + K) = DMY_NDX(1,SUM(FULL_LOCAL_DOF(1:2))+I)
			NDX(2,SUM(LOCAL_DOF(1:2)) + K) = DMY_NDX(2,SUM(FULL_LOCAL_DOF(1:2))+I)
		ENDIF
	ENDDO

	IF (K.NE.LOCAL_DOF(3)) THEN
		PRINT*, 'ERROR - LOCAL_DOF(3) : ', 'LOCAL_DOF(3) = ', LOCAL_DOF(3), 'K = ', K
	ENDIF
	
	K = 0
	DO I=1, FULL_LOCAL_DOF(4)
		IF (DMY_NDX(2, SUM(FULL_LOCAL_DOF(1:3)) + I).GT.(NUMBS(4,2) - BASIS_KVEC(4,2)%POLY_ORDER)-1) THEN
! 		IF (DMY_NDX(2, SUM(FULL_LOCAL_DOF(1:3)) + I).GT.(NUMBS(4,2)-2)) THEN
		ELSE
			IF (DMY_NDX(2, SUM(FULL_LOCAL_DOF(1:3)) + I)==0) THEN
			ELSE
				K = K + 1
				NDX(1,SUM(LOCAL_DOF(1:3)) + K) = DMY_NDX(1,SUM(FULL_LOCAL_DOF(1:3))+I)
				NDX(2,SUM(LOCAL_DOF(1:3)) + K) = DMY_NDX(2,SUM(FULL_LOCAL_DOF(1:3))+I)
			ENDIF
		ENDIF
	ENDDO

	IF (K.NE.LOCAL_DOF(4)) THEN
		PRINT*, 'ERROR - LOCAL_DOF(4) : ', 'LOCAL_DOF(4) = ', LOCAL_DOF(4), 'K = ', K
	ENDIF
	
	!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	
	WRITE(*,*)
	WRITE(*,*) '<<< SET GLOBAL INDEX : DONE >>>'
	WRITE(*,*)

! CONSTRUCT THE FRAME OF LOCAL INTEGRAL REGIONS
	IR_GRID(:,1,1) = 0.D0
	IR_GRID(:,2,1) = 0.D0

	!! Support of NURBS basis
	DO II = 1, NUM_IGA_PATCH
		K = 1
		DO I=1, IGA_KVEC(II,1)%LENGTH
			K = K + 1
			IF (DABS(IGA_KVEC(II,1)%KNOTS(I-1) - IGA_KVEC(II,1)%KNOTS(I)).LE.EPS) THEN
				K = K - 1
			ELSE
				IR_GRID(II,1,K) = IGA_KVEC(II,1)%KNOTS(I)
			ENDIF
		ENDDO
		NUMIR(II,1) = K
	ENDDO
	
	DO II = 1, NUM_IGA_PATCH
		K = 1
		DO I=1, IGA_KVEC(II,2)%LENGTH
			K = K + 1
			IF (DABS(IGA_KVEC(II,2)%KNOTS(I-1) - IGA_KVEC(II,2)%KNOTS(I)).LE.EPS) THEN
				K = K - 1
			ELSE
				IR_GRID(II,2,K) = IGA_KVEC(II,2)%KNOTS(I)
			ENDIF
		ENDDO
		NUMIR(II,2) = K
	ENDDO
	
	DO II = 1, NUM_EGM_PATCH
		K = 1
		DO I=1, EGM_KVEC(II,1)%LENGTH
			K = K + 1
			IF (DABS(EGM_KVEC(II,1)%KNOTS(I-1) - EGM_KVEC(II,1)%KNOTS(I)).LE.EPS) THEN
				K = K - 1
			ELSE
				IR_GRID(NUM_IGA_PATCH + II,1,K) = EGM_KVEC(II,1)%KNOTS(I)
			ENDIF
		ENDDO
		NUMIR(NUM_IGA_PATCH + II,1) = K
	ENDDO
	
	DO II = 1, NUM_EGM_PATCH
		K = 1
		DO I=1, EGM_KVEC(II,2)%LENGTH
			K = K + 1
			IF (DABS(EGM_KVEC(II,2)%KNOTS(I-1) - EGM_KVEC(II,2)%KNOTS(I)).LE.EPS) THEN
				K = K - 1
			ELSE
				IR_GRID(NUM_IGA_PATCH + II,2,K) = EGM_KVEC(II,2)%KNOTS(I)
			ENDIF
		ENDDO
		NUMIR(NUM_IGA_PATCH + II,2) = K
	ENDDO

	WRITE(*,*)
	WRITE(*,*) '<<< SET INTEGRAL REGION : DONE >>>'
	WRITE(*,*)


! SET INDEX OF BASIS FUNCTIONS ON BOUNDARY WILL BE IMPOSED BY NEUMANN BOUNDARY CONDITIONS
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	ALLOCATE(BD_MASK(DOF))
	BD_MASK(:) = .FALSE.
	BD_DOF = 0

	DO I=1, NM_NUMBD
		DO J=1, MAX_LENGTH
			NM_BDNDX(I,J)%LC_NDX = (/-1, -1/)
			NM_BDNDX(I,J)%LC_INTERFACE_NDX = (/-1, -1/)
		ENDDO
	ENDDO
	NM_BDNDX(1:NM_NUMBD,1:MAX_LENGTH)%GL_NDX = -1
	NM_BDNDX(1:NM_NUMBD,1:MAX_LENGTH)%LC_NUM = -1
	NM_BDNDX(1:NM_NUMBD,1:MAX_LENGTH)%SLAVE_PATCH_NDX = -1
	NM_BDNDX(1:NM_NUMBD,1:MAX_LENGTH)%SLAVE_GAMMA = -1
	
	! NEUMANN BOUNDARY CONDITION
	
! 	K = 0
! 	DO I=1, LOCAL_DOF(1)
! 		IF (NDX(2,I)==0) THEN
! 			K = K + 1
! 			NM_BDNDX(1,K)%LC_NDX(:) = NDX(:,I)
! 			NM_BDNDX(1,K)%GL_NDX = I
! 			NM_BDNDX(1,K)%PATCH_NDX = 1
! 		ENDIF
! 	ENDDO
! 	DO I=SUM(LOCAL_DOF(1:3))+1, SUM(LOCAL_DOF(1:4))
! 		IF (NDX(1,I)==NUMBS(4,1)-1) THEN
! 			K = K + 1
! 			NM_BDNDX(1,K)%LC_NDX(:) = NDX(:,I)
! 			NM_BDNDX(1,K)%GL_NDX = I
! 			NM_BDNDX(1,K)%PATCH_NDX = 4
! 		ENDIF
! 	ENDDO
! 	NM_BDNDX(1,:)%LC_NUM = K
! 
! 	K = 0
! 	DO I=1, LOCAL_DOF(1)
! 		IF (NDX(1,I)==NUMBS(1,1)-1) THEN
! 			K = K + 1
! 			NM_BDNDX(2,K)%LC_NDX(:) = NDX(:,I)
! 			NM_BDNDX(2,K)%GL_NDX = I
! 			NM_BDNDX(2,K)%PATCH_NDX = 1
! 		ENDIF
! 	ENDDO
! 	NM_BDNDX(2,:)%LC_NUM = K
! 
! 	K = 0
! 	DO I=1, LOCAL_DOF(1)
! 		IF (NDX(2,I)==NUMBS(1,2)-1) THEN
! 			K = K + 1
! 			NM_BDNDX(3,K)%LC_NDX(:) = NDX(:,I)
! 			NM_BDNDX(3,K)%GL_NDX = I
! 			NM_BDNDX(3,K)%PATCH_NDX = 1
! 		ENDIF
! 	ENDDO
! 	DO I=LOCAL_DOF(1) + 1, SUM(LOCAL_DOF(1:2))
! 		IF (NDX(2,I)==NUMBS(2,2)-1) THEN
! 			K = K + 1
! 			NM_BDNDX(3,K)%LC_NDX(:) = NDX(:,I)
! 			NM_BDNDX(3,K)%GL_NDX = I
! 			NM_BDNDX(3,K)%PATCH_NDX = 2
! 		ENDIF
! 	ENDDO
! 	NM_BDNDX(3,:)%LC_NUM = K
! 	
! 	K = 0
! 	DO I=LOCAL_DOF(1) + 1, SUM(LOCAL_DOF(1:2))
! 		IF (NDX(1,I)==0) THEN
! 			K = K + 1
! 			NM_BDNDX(4,K)%LC_NDX(:) = NDX(:,I)
! 			NM_BDNDX(4,K)%GL_NDX = I
! 			NM_BDNDX(4,K)%PATCH_NDX = 2
! 		ENDIF
! 	ENDDO
! 	DO I=SUM(LOCAL_DOF(1:2)) + 1, SUM(LOCAL_DOF(1:3))
! 		IF (NDX(1,I)==0) THEN
! 			K = K + 1
! 			NM_BDNDX(4,K)%LC_NDX(:) = NDX(:,I)
! 			NM_BDNDX(4,K)%GL_NDX = I
! 			NM_BDNDX(4,K)%PATCH_NDX = 3
! 		ENDIF
! 	ENDDO
! 	NM_BDNDX(4,:)%LC_NUM = K
! 	
! 	K = 0
! 	DO I=SUM(LOCAL_DOF(1:2)) + 1, SUM(LOCAL_DOF(1:3))
! 		IF (NDX(2,I)==0) THEN
! 			K = K + 1
! 			NM_BDNDX(5,K)%LC_NDX(:) = NDX(:,I)
! 			NM_BDNDX(5,K)%GL_NDX = I
! 			NM_BDNDX(5,K)%PATCH_NDX = 3
! 		ENDIF
! 	ENDDO
! 	NM_BDNDX(5,:)%LC_NUM = K
! 	
! 	K = 0
! 	DO I=SUM(LOCAL_DOF(1:2)) + 1, SUM(LOCAL_DOF(1:3))
! 		IF (NDX(1,I)==NUMBS(3,1)-1) THEN
! 			K = K + 1
! 			NM_BDNDX(6,K)%LC_NDX(:) = NDX(:,I)
! 			NM_BDNDX(6,K)%GL_NDX = I
! 			NM_BDNDX(6,K)%PATCH_NDX = 3
! 		ENDIF
! 	ENDDO
! 	DO I=SUM(LOCAL_DOF(1:3)) + 1, SUM(LOCAL_DOF(1:4))
! 		IF (NDX(1,I)==0) THEN
! 			K = K + 1
! 			NM_BDNDX(6,K)%LC_NDX(:) = NDX(:,I)
! 			NM_BDNDX(6,K)%GL_NDX = I
! 			NM_BDNDX(6,K)%PATCH_NDX = 4
! 		ENDIF
! 	ENDDO
! 	NM_BDNDX(6,:)%LC_NUM = K

! SET INDEX OF BASIS FUNCTIONS ON BOUNDARY WILL BE IMPOSED BY DIRICHLET BOUNDARY CONDITION
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	DO I=1, DR_NUMBD
		DO J=1, MAX_LENGTH
			DR_BDNDX(I,J)%LC_NDX = (/-1, -1/)
		ENDDO
	ENDDO
	DR_BDNDX(1:DR_NUMBD,1:MAX_LENGTH)%GL_NDX = -1
	DR_BDNDX(1:DR_NUMBD,1:MAX_LENGTH)%LC_NUM = -1

	K = 0
	DO I=1, LOCAL_DOF(1)
		IF (NDX(2,I)==0 .OR. NDX(1,I)==NUMBS(1,1)-1 .OR. NDX(2,I)==NUMBS(1,2)-1) THEN
! 			IF (I.NE.1) THEN
				K = K + 1
				DR_BDNDX(1,K)%LC_NDX(:) = NDX(:,I)
				DR_BDNDX(1,K)%GL_NDX = I
				BD_MASK(I)=.TRUE.
				BD_DOF = BD_DOF + 1
! 			ENDIF
		ENDIF
	ENDDO
	DR_BDNDX(1,:)%LC_NUM = K
	
	K = 0
	DO I=LOCAL_DOF(1)+1, SUM(LOCAL_DOF(1:2))
			IF (NDX(1,I)==0 .OR. NDX(2,I)==NUMBS(2,2)-1) THEN
			K = K + 1
			DR_BDNDX(2,K)%LC_NDX(:) = NDX(:,I)
			DR_BDNDX(2,K)%GL_NDX = I
			BD_MASK(I)=.TRUE.
			BD_DOF = BD_DOF + 1
		ENDIF
	ENDDO
	DR_BDNDX(2,:)%LC_NUM = K

	K = 0
	DO I=SUM(LOCAL_DOF(1:2)) + 1, SUM(LOCAL_DOF(1:3))
			IF (NDX(1,I)==0 .OR. NDX(2,I)==0 .OR. NDX(1,I)==NUMBS(3,1)-1) THEN
			K = K + 1
			DR_BDNDX(3,K)%LC_NDX(:) = NDX(:,I)
			DR_BDNDX(3,K)%GL_NDX = I
			BD_MASK(I)=.TRUE.
			BD_DOF = BD_DOF + 1
		ENDIF
	ENDDO
	DR_BDNDX(3,:)%LC_NUM = K

	K = 0
	DO I=SUM(LOCAL_DOF(1:3)) + 1, SUM(LOCAL_DOF(1:4))
		IF (NDX(1,I)==0 .OR. NDX(1,I)==NUMBS(4,1)-1) THEN
			IF (NDX(2,I).NE.0) THEN
				K = K + 1
				DR_BDNDX(4,K)%LC_NDX(:) = NDX(:,I)
				DR_BDNDX(4,K)%GL_NDX = I
				BD_MASK(I)=.TRUE.
				BD_DOF = BD_DOF + 1
			ENDIF
		ENDIF
	ENDDO
	DR_BDNDX(4,:)%LC_NUM = K


! 	PRINT*, 'DR_BDNDX_LC_NUM :', K

	!------------------------------------------------------------------------------------------------------------------------!

	!! Zero hohomogeneous boundary conditions
	DO I=1, DR_NUMBD
		DO J=1, MAX_LENGTH
			ZERO_BDNDX(I,J)%LC_NDX = (/0, 0/)
		ENDDO
	ENDDO
	ZERO_BDNDX(1:DR_NUMBD,1:MAX_LENGTH)%GL_NDX = 0
	ZERO_BDNDX(1:DR_NUMBD,1:MAX_LENGTH)%LC_NUM = 0

	K = 0
! 	DO I=1, LOCAL_DOF(1)
! 		IF (NDX(1,I)==0 .AND. NDX(2,I)==0) THEN
! 			K = K + 1
! 			ZERO_BDNDX(1,K)%LC_NDX(:) = NDX(:,I)
! 			ZERO_BDNDX(1,K)%GL_NDX = I
! 			BD_MASK(I)=.TRUE.
! 			BD_DOF = BD_DOF + 1
! 		ENDIF
! 	ENDDO
	ZERO_BDNDX(1,:)%LC_NUM = K
	
	K = 0
! 	DO I=LOCAL_DOF(1)+1, SUM(LOCAL_DOF(1:2))
! 			IF (NDX(1,I)==0 .OR. NDX(2,I)==NUMBS(2,2)-1) THEN
! 			K = K + 1
! 			ZERO_BDNDX(2,K)%LC_NDX(:) = NDX(:,I)
! 			ZERO_BDNDX(2,K)%GL_NDX = I
! 			BD_MASK(I)=.TRUE.
! 			BD_DOF = BD_DOF + 1
! 		ENDIF
! 	ENDDO
	ZERO_BDNDX(2,:)%LC_NUM = K
	
	K = 0
! 	DO I=SUM(LOCAL_DOF(1:2))+1, SUM(LOCAL_DOF(1:3))
! 		IF (NDX(1,I)==NUMBS(3,1)-1) THEN
! 			K = K + 1
! 			ZERO_BDNDX(3,K)%LC_NDX(:) = NDX(:,I)
! 			ZERO_BDNDX(3,K)%GL_NDX = I
! 			BD_MASK(I)=.TRUE.
! 			BD_DOF = BD_DOF + 1
! 		ENDIF
! 	ENDDO
	ZERO_BDNDX(3,:)%LC_NUM = K
	
! 	K = 0
! 	DO I=SUM(LOCAL_DOF(1:3))+1, SUM(LOCAL_DOF(1:4))
! ! 		IF (NDX(1,I)==(NUMBS(4,1)-1) .OR. (NDX(1,I)==0 .AND. NDX(2,I)==0)) THEN
! 		IF (NDX(1,I)==(NUMBS(4,1)-1) .OR. NDX(1,I)==0) THEN
! 			K = K + 1
! 			ZERO_BDNDX(4,K)%LC_NDX(:) = NDX(:,I)
! 			ZERO_BDNDX(4,K)%GL_NDX = I
! 			BD_MASK(I)=.TRUE.
! 			BD_DOF = BD_DOF + 1
! 		ENDIF
! 	ENDDO
! 	ZERO_BDNDX(4,:)%LC_NUM = K
	K = 0
! 	DO I = SUM(LOCAL_DOF(1:3))+1, SUM(LOCAL_DOF(1:4))
! ! 		IF ((NDX(1,I)==(NUMBS(4,1)-1) .AND. NDX(2,I)==0) .OR. (NDX(1,I)==0 .AND. NDX(2,I)==0)) THEN
! 		IF (NDX(2,I)==0) THEN
! 			K = K + 1
! 			ZERO_BDNDX(4,K)%LC_NDX(:) = NDX(:,I)
! 			ZERO_BDNDX(4,K)%GL_NDX = I
! 			BD_MASK(I)=.TRUE.
! 			BD_DOF = BD_DOF + 1
! 		ENDIF
! 	ENDDO
	ZERO_BDNDX(4,:)%LC_NUM = K
	
	!!---------------------------------------------------------------------------------------------------------------!!
	
! Index of Interface on Boundary
	K = 0
	DO I = 1, UBOUND(INTERFACE_NDX,1)
		DO PATCH = 1, NUM_IGA_PATCH
			DO J = 1, DR_BDNDX(PATCH, 1)%LC_NUM
				IF (INTERFACE_NDX(I)%GL_NDX.EQ.DR_BDNDX(PATCH,J)%GL_NDX) THEN
					K = K + 1
				ENDIF
			ENDDO
		ENDDO
	ENDDO
	ALLOCATE(INTERFACE_BDNDX(K))
	K = 0
	DO I = 1, UBOUND(INTERFACE_NDX,1)
		DO PATCH = 1, NUM_IGA_PATCH
			DO J = 1, DR_BDNDX(PATCH, 1)%LC_NUM
				IF (INTERFACE_NDX(I)%GL_NDX.EQ.DR_BDNDX(PATCH,J)%GL_NDX) THEN
					K = K + 1
					INTERFACE_BDNDX(K) = INTERFACE_NDX(I)
					INTERFACE_BDNDX(K)%GL_BDNDX = SUM(DR_BDNDX(1:PATCH-1,1)%LC_NUM) + J
				ENDIF
			ENDDO
		ENDDO
	ENDDO

	!!	Verify true or false of interface index in Neumann boundary index
	!!	Put the information of interface into Nuemann boundary data
	DO I=1, NM_NUMBD
		DO J=1, NM_BDNDX(I,1)%LC_NUM
			DO K=1, UBOUND(INTERFACE_BDNDX,1)
				
				IF (NM_BDNDX(I,J)%GL_NDX.EQ.INTERFACE_BDNDX(K)%GL_NDX) THEN
					NM_BDNDX(I,J)%INTERFACE_LG = .TRUE.
					IF (INTERFACE_BDNDX(K)%SLAVE_PATCH_NDX(2)==3) THEN
						NM_BDNDX(I,J)%LC_INTERFACE_NDX(1:2) = INTERFACE_BDNDX(K)%LC_NDX(5:6)
						NM_BDNDX(I,J)%SLAVE_PATCH_NDX = INTERFACE_BDNDX(K)%SLAVE_PATCH_NDX(2)
						NM_BDNDX(I,J)%SLAVE_GAMMA = 6
					ELSE
						NM_BDNDX(I,J)%LC_INTERFACE_NDX(1:2) = INTERFACE_BDNDX(K)%LC_NDX(3:4)
						NM_BDNDX(I,J)%SLAVE_PATCH_NDX = INTERFACE_BDNDX(K)%SLAVE_PATCH_NDX(1)
					ENDIF
					
					IF (NM_BDNDX(I,J)%SLAVE_PATCH_NDX==2 .AND. NM_BDNDX(I,J)%SLAVE_GAMMA==-1) THEN
						NM_BDNDX(I,J)%SLAVE_GAMMA = 3
					ELSEIF (NM_BDNDX(I,J)%SLAVE_PATCH_NDX==3 .AND. NM_BDNDX(I,J)%SLAVE_GAMMA==-1) THEN
						NM_BDNDX(I,J)%SLAVE_GAMMA = 4
					ENDIF
						
					GOTO 178
				
				ELSE
					NM_BDNDX(I,J)%INTERFACE_LG = .FALSE.
				ENDIF
			
			ENDDO
			178 CONTINUE
		ENDDO
	ENDDO
	
	WRITE(*,*)
	WRITE(*,*) '<<< SET LOCAL INDEX CORRESPONDING BASIS FUNCTIONS ON BOUNDARY : DONE >>>'
	WRITE(*,*)

	!!  GENERATE BINOMIAL COEFFICIENTS

	DO I = 1, MAX_DIFF_ORDER
		DO J = 0, MAX_DIFF_ORDER
			BINOM(I,J) = 1.0D0
		ENDDO
	ENDDO

	BINOM(1,0) = 1.0D0
	BINOM(1,1) = 1.0D0
	DO I = 2, MAX_DIFF_ORDER
		BINOM(I,0) = BINOM(I-1,0)
		DO J = 1, I-1
			BINOM(I,J) = BINOM(I-1,J-1) + BINOM(I-1,J)
		ENDDO
		BINOM(I,I) = BINOM(I-1,I-1)
	ENDDO

END SUBROUTINE GET_GEO

INTEGER FUNCTION GET_IGA_PATCH_INDX(PHY_PT)
	
	TYPE(POINT2D), INTENT(IN) :: PHY_PT
	REAL*8 :: R, THETA
	
	GET_IGA_PATCH_INDX = 0
	
	CALL GET_RTHETA(R, THETA, PHY_PT)
	
! 	IF (DABS(PHY_PT%X).LE.EPS .AND. DABS(PHY_PT%Y).LE.EPS) THEN
! 		GET_IGA_PATCH_INDX = 1
! 	ELSEIF (DABS(R).LE.EPS) THEN
! 		GET_IGA_PATCH_INDX = 1
! 	ELSEIF (PHY_PT%X.GE.EPS .AND. PHY_PT%Y.GE.EPS) THEN
! 		GET_IGA_PATCH_INDX = 1
! 	ELSEIF (PHY_PT%X.GE.EPS .AND. DABS(PHY_PT%Y).LE.EPS) THEN
! 		GET_IGA_PATCH_INDX = 1
! 	ELSEIF (DABS(PHY_PT%X).LE.EPS .AND. PHY_PT%Y.GE.EPS) THEN
! 		GET_IGA_PATCH_INDX = 1
! 	ELSEIF (PHY_PT%X.LT.EPS .AND. PHY_PT%Y.GE.EPS) THEN
! 		GET_IGA_PATCH_INDX = 2
! 	ELSEIF (PHY_PT%X.LT.EPS .AND. DABS(PHY_PT%Y).LE.EPS) THEN
! 		GET_IGA_PATCH_INDX = 2
! 	ELSEIF (PHY_PT%X.LT.EPS .AND. PHY_PT%Y.LT.EPS) THEN
! 		GET_IGA_PATCH_INDX = 3
! 	ENDIF

	IF (GET_IGA_PATCH_INDX==0) THEN
		IF 	  (PHY_PT%Y.GE.(-PHY_PT%X-DSQRT(2.D0))  .AND. PHY_PT%Y.LE.-PHY_PT%X .AND. &
					PHY_PT%Y.GE.(PHY_PT%X-DSQRT(2.D0))   .AND. PHY_PT%Y.LE.PHY_PT%X) THEN
					GET_IGA_PATCH_INDX = 1
		ELSEIF (PHY_PT%Y.LE.(-PHY_PT%X+DSQRT(2.D0)) .AND. PHY_PT%Y.GE.-PHY_PT%X .AND. &
					PHY_PT%Y.GE.(PHY_PT%X-DSQRT(2.D0)) 	.AND. PHY_PT%Y.LE.PHY_PT%X) THEN
					GET_IGA_PATCH_INDX = 2
		ELSEIF (PHY_PT%Y.LE.(-PHY_PT%X+DSQRT(2.D0)) .AND. PHY_PT%Y.GE.-PHY_PT%X .AND. &
					PHY_PT%Y.LE.(PHY_PT%X+DSQRT(2.D0)) 	.AND. PHY_PT%Y.GE.PHY_PT%X) THEN
					GET_IGA_PATCH_INDX = 3
		ENDIF
	ENDIF
	
	IF (GET_IGA_PATCH_INDX.NE.0) THEN
		GOTO 1
	ENDIF
	
	IF (DABS(PHY_PT%X).LE.EPS .AND. DABS(PHY_PT%Y).LE.EPS) THEN
		GET_IGA_PATCH_INDX = 1
	ELSEIF (THETA.GE.-3.D0*PI*0.25D0 .AND. THETA.LE.-1.D0*PI*0.25D0) THEN
		GET_IGA_PATCH_INDX = 1
	ELSEIF (THETA.GE.-1.D0*PI*0.25D0 .AND. THETA.LE.1.D0*PI*0.25D0) THEN
		GET_IGA_PATCH_INDX = 2
	ELSEIF (THETA.GE.1.D0*PI*0.25D0 .AND. THETA.LE.3.D0*PI*0.25D0) THEN
		GET_IGA_PATCH_INDX = 3
	ENDIF
	
	IF (GET_IGA_PATCH_INDX==0) THEN
		PRINT*, 'ERROR - GET_IGA_PATCH_INDX : FAILED TO VARIFY IGA_PATCH!'
		PRINT*, PHY_PT
		STOP
	ENDIF
	
	1 CONTINUE
	
END FUNCTION GET_IGA_PATCH_INDX

CHARACTER(LEN=1) FUNCTION GET_GAMMA_HAT(PT)
	TYPE(POINT2D), INTENT(IN) :: PT
	
	IF (DABS(PT%X).LE.EPS .AND. DABS(PT%Y).GT.EPS) THEN
		GET_GAMMA_HAT = 'L'
	ELSEIF (DABS(PT%X - 1.D0).LE.EPS .AND. DABS(PT%Y).GT.EPS) THEN
		GET_GAMMA_HAT = 'R'
	ELSEIF (DABS(PT%X).GT.EPS .AND. DABS(PT%Y).LE.EPS) THEN
		GET_GAMMA_HAT = 'B'
	ELSEIF (DABS(PT%X).GT.EPS .AND. DABS(PT%Y - 1.D0).LE.EPS) THEN
		GET_GAMMA_HAT = 'T'
	ENDIF
	
END FUNCTION GET_GAMMA_HAT

END MODULE GEOMETRY
