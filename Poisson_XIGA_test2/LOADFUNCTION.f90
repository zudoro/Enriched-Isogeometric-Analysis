MODULE LOADFUNCTION

	USE GEOMETRY

	IMPLICIT NONE

CONTAINS

TYPE(POINT2D) FUNCTION EX_DISP(PT2D, PATCH)

	INTEGER, INTENT(IN) :: PATCH
	TYPE(POINT2D), INTENT(IN) :: PT2D
	TYPE(POINT2D) :: PHY_PT
	REAL*8 :: R, THETA, X, Y

	PHY_PT = GET_PHY_PT(PT2D, PATCH)
	
	X = PHY_PT%X; Y = PHY_PT%Y
	
	CALL GET_RTHETA(R, THETA, PHY_PT)
	
	IF (PROBLEM.EQ.1) THEN
		EX_DISP%X = X*Y
	ELSEIF (PROBLEM.EQ.2) THEN
		EX_DISP%X = R**0.5D0*DSIN(THETA*0.5D0)
	ELSEIF (PROBLEM.EQ.3) THEN
		EX_DISP%X = DSQRT(R)*(1.D0-R)*(DSIN(0.5D0*THETA) + DSIN(1.5D0*THETA))
	ENDIF
	
END FUNCTION EX_DISP


TYPE(POINT2D) FUNCTION LDFT2D(PT2D, PATCH)

	INTEGER, INTENT(IN) :: PATCH
	TYPE(POINT2D), INTENT(IN) :: PT2D
	TYPE(POINT2D) :: PHY_PT
	REAL*8 :: X, Y, R, THETA

	PHY_PT = GET_PHY_PT(PT2D, PATCH)
	
	X = PHY_PT%X; Y = PHY_PT%Y
	
	CALL GET_RTHETA(R, THETA, PHY_PT)
	
	IF (PROBLEM.EQ.1) THEN
		LDFT2D%X = 0.D0
	ELSEIF (PROBLEM.EQ.2) THEN
		LDFT2D%X = 0.D0
	ELSEIF (PROBLEM.EQ.3) THEN
		LDFT2D%X = 2.D0*(1.D0 + R + 2.D0*DCOS(THETA))*DSIN(0.5D0*THETA)/R**(1.5D0)
	ENDIF

END FUNCTION LDFT2D

END MODULE LOADFUNCTION