#include "motor_control.h"

//LOOK UP TABLES
const uint8_t BRIDGE_STEPS_FORWARD[8][6] =   // Motor step //A B C
{
    { false,false   ,   false,false   ,  false,false },  // HighZ
    { false,false   ,   false, true   ,  true, false },  // h 1, step 6
    { false,true    ,   true ,false   ,  false,false },  // h 2, step 4
    { false,true    ,   false,false   ,  true ,false },  // h 3, step 5
    { true ,false   ,   false,false   ,  false,true  },  // h 4, step 2 -
    { true ,false   ,   false,true    ,  false,false },  // h 5, step 1 -
    { false,false   ,   true, false   ,  false,true  },  // h 6, step 3
    { false,false   ,   false,false   ,  false,false },  // HighZ
};

const uint8_t BRIDGE_STEPS_REVERSE[8][6] =   // Motor step //A B C
{
    { false,false   ,   false,false   ,  false,false },  // HighZ

    { false,false   ,   true ,false   ,  false, true },  // h 1, step 6
    { true ,false   ,   false,true    ,  false,false },  // h 2, step 4
    { true ,false   ,   false,false   ,  false,true  },  // h 3, step 5
    { false,true    ,   false,false   ,  true ,false },  // h 4, step 2
    { false,true    ,   true ,false   ,  false,false },  // h 5, step 1
    { false,false   ,   false, true   ,  true ,false },  // h 6, step 3

    { false,false   ,   false,false   ,  false,false },  // HighZ

};

//const uint8_t ENCODER_CHANGES[8][8] = 
//{
//	//  1  2  3  4  5  6
//	{0, 0, 0, 0, 0, 0, 0, 0},
//	{0, 0, 2, 1, 2, 1, 3, 0}, // 1
//	{0, 2, 0, 1, 2, 3, 1, 0}, // 2
//	{0, 1, 1, 0, 3, 2, 2, 0}, // 3
//	{0, 2, 2, 3, 0, 1, 1, 0}, // 4
//	{0, 1, 3, 2, 1, 0, 2, 0}, // 5
//	{0, 3, 1, 2, 1, 1, 0, 0}, // 6
//	{0, 0, 0, 0, 0, 0, 0, 0},
//};

const uint8_t ENCODER_CHANGES[8][8] = 
{
	//  1  2  3  4  5  6
	{0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 4, 5, 2, 1, 3, 0}, // 1
	{0, 2, 0, 1, 4, 3, 5, 0}, // 2
	{0, 1, 5, 0, 3, 2, 4, 0}, // 3
	{0, 4, 2, 3, 0, 5, 1, 0}, // 4
	{0, 5, 3, 4, 1, 0, 2, 0}, // 5
	{0, 3, 1, 2, 5, 4, 0, 0}, // 6
	{0, 0, 0, 0, 0, 0, 0, 0},
};

//-------------------------------------------------------------------------------------------------
// FUNCTIONS FOR SAMPLING PEDALS AND FORWARD/REVERSE GEAR
//-------------------------------------------------------------------------------------------------

/*
	Description: enables sampling the brake and acceleration pedals (hadc1, hadc2)
	
	Input parameters: 	None
	
	Return value:		None
*/
void startADC_HALs(){
	HAL_ADC_Start(&hadc1);
  HAL_ADC_Start(&hadc2);
}

/*
	Description: samples the brake pedal (hadc2)
	
	Input parameters: 	None
	
	Return value:		uint16_t - sampled brake pedal value
*/
uint16_t getRawBrakeValue(){
	return HAL_ADC_GetValue(&hadc2);
}

/*
	Description: return a measuremnt for the currnt
	
	Input parameters: 	None
	
	Return value:		int - sampled current value
*/
int getCurrentMeasurement(){
	int raw_analog = HAL_ADC_GetValue(&hadc2);
	int amp0 = 0; //int amp0 = 3190;
	float scale = 1;//float scale = 5 / (4096 * 0.066); //voltage / (10^12 * slope)
	int current = (raw_analog - amp0) * scale;
	return current;
}

/*
	Description: samples the acceleration pedal (hadc1)
	
	Input parameters: 	None
	
	Return value:		uint16_t - sampled acceleration pedal value
*/
uint16_t getRawAccelValue(){
	return HAL_ADC_GetValue(&hadc1);
}

/*
	Description: scale a value given the minimum value it can take and its range (difference between
	maximum and minimum possible values). For instance, value 1 with minum value 0 and range 2 is 0.5
	
	Input parameters: 	uint16_t curr_val
	
	Return value:		bool - True if hall sensors are in an impossible state, False otherwise
*/
float scaleValue(uint16_t curr_val, uint16_t min_val, uint16_t range){
	return ((curr_val - min_val) / (float)(range));
}

/*
	Description: returns the brake pedal value scaled to the maximum duty cicle (between 0 and max duty cicle)
	
	Input parameters: 	uint16_t scaledValue - the scaled brake pedal value will be stored here
											uint16_t min_val - the minimum value that the raw pedal value can have
											uint16_t range - the difference between the raw brake pedal maximum value and minimum value
	
	Return value:		None
*/
void getScaledBrakeValue(uint16_t* scaledValue, uint16_t min_val, uint16_t range){
	uint16_t rawValue = getRawBrakeValue(); //Sample raw value
	if (rawValue <= min_val) {
		(*scaledValue) = 0;
	} else{
		(*scaledValue) = (int)(4200*scaleValue(rawValue, min_val, range)); //Scale
	}
}

/*
	Description: returns the acceleration pedal value scaled to the maximum duty cicle (between 0 
	and max duty cicle)
	
	Input parameters: 	uint16_t scaledValue - the scaled acceleration pedal value will be stored here
											uint16_t min_val - the minimum value that the raw acceleration value can have
											uint16_t range - 	the difference between the raw acceleration pedal maximum 
																				value and minimum value
	
	Return value:		None
*/
void getScaledAccelValue(uint16_t* scaledValue, uint16_t min_val, uint16_t range){
	uint16_t rawValue = getRawAccelValue(); //Sample raw
	if (rawValue <= min_val) {
		(*scaledValue) = 0;
	} else{
		(*scaledValue) = (int)(4200*scaleValue(rawValue, min_val, range)); //Scale
	}
	if (*scaledValue < 30){ //Additional threshold to avoid accidental acceleration
		(*scaledValue) = 0;
	}
}

/*
	Description: samples the gear forward/backward switch (Fw_Rev_switch_Pin)
	
	Input parameters: 	bool gearForward - the gear forward/backward switch value will be stored here
	
	Return value:		None
*/
void getGearForward(bool* gearForward){
	(*gearForward) = (bool)HAL_GPIO_ReadPin(rev_switch_GPIO_Port, rev_switch_Pin);
}


//-------------------------------------------------------------------------------------------------
// FUNCTIONS FOR COMPUTING THE PHASES
//-------------------------------------------------------------------------------------------------

/*
	Description: initializes the array containing all 6 phases to false (motor will not move)
	
	Input parameters: 	bool* Phases - the 6 phases will be stored here
														Phases[0] = Phase 1 High
														Phases[1] = Phase 1 Low
														Phases[2] = Phase 2 High
														Phases[3] = Phase 2 Low
														Phases[4] = Phase 2 High
														Phases[5] = Phase 2 Low
	
	Return value: None
*/
void initPhases(bool* Phases){
	for(int i = 0; i < 6; i++){
		*(Phases + i) = false;
	}
}

/*
	Description: initializes the array containing the hall sensor data to an arbitrary value
	
	Input parameters: 	bool* Halls - array containing sample hall sensor data
													Halls[0] = hall sensor 1
													Halls[1] = hall sensor 2
													Halls[2] = hall sensor 3
	
	Return value: None
*/
void initHalls(bool* Halls){
	*(Halls + 0) = true;
	*(Halls + 1) = true;
	*(Halls + 2) = false;
}

/*
	Description: check if the hall position is in an impossible state (therefore malfunctioning)
	Invalid states are 0 (000) and 7 (111).
	
	Input parameters: 	unit8_t* hallPosition - computed hall position
	
	Return value:		bool - True if hall sensors are in an impossible state, False otherwise
*/
bool checkHallSensorMalfunction(uint8_t hallPosition){
	return ((hallPosition > 6) || (hallPosition <1));
}

/*
	Description: samples all 3 Hall Sensors and stores the values into the input boolean array 'Halls'
	
	Input parameters: 	bool* Halls - sampled hall sensor data will be stored in this array
													Halls[0] = hall sensor 1
													Halls[1] = hall sensor 2
													Halls[2] = hall sensor 3
	
	Return value: None
*/
void readHallSensors(bool* Halls){
	*(Halls + 0) = HAL_GPIO_ReadPin(GPIOB, Hall1_Pin);
	*(Halls + 1) = HAL_GPIO_ReadPin(GPIOB, Hall2_Pin);
	*(Halls + 2) = HAL_GPIO_ReadPin(GPIOB, Hall3_Pin);
}

/*
	Description: computes the hall sensor position given the input sampled hall sensor data
	The hall position serves as an input for the bridge look up table. (BRIDGE_STEPS_REVERSE, 
	BRIDGE_STEPS_FORWARD)
	
	Input parameters: 	bool* Halls - array containing sample hall sensor data
													Halls[0] = hall sensor 1
													Halls[1] = hall sensor 2
													Halls[2] = hall sensor 3
											unit8_t* hallPosition - computed hall position will be stored here
	
	Return value: None
*/
void getHallPosition(bool Halls[3], uint8_t* hallPosition){
	(*hallPosition) = (Halls[0]<<2) + (Halls[1]<<1) + (Halls[2]);
}

/*
	Description: computes all 6 phases given the hall position by looking into the look up table
	stored in BRIDGE_STEPS_FORWARD
	
	Input parameters: 	bool* Phases - the 6 computed phases will be stored here
														Phases[0] = Phase 1 High
														Phases[1] = Phase 1 Low
														Phases[2] = Phase 2 High
														Phases[3] = Phase 2 Low
														Phases[4] = Phase 2 High
														Phases[5] = Phase 2 Low
											unit8_t* hallPosition - contains the computed hall position
	
	Return value: None
*/
void getPhasesForward(bool* Phases, uint8_t hallPosition){
	for(int i = 0; i < 6; i++){ //For all 6 phases
		*(Phases + i) = BRIDGE_STEPS_FORWARD[hallPosition][i]; //Access look up table 
	}
}

/*
	Description: computes all 6 phases given the hall position by looking into the look up table
	stored in BRIDGE_STEPS_REVERSE
	
	Input parameters: 	bool* Phases - the 6 computed phases will be stored here
														Phases[0] = Phase 1 High
														Phases[1] = Phase 1 Low
														Phases[2] = Phase 2 High
														Phases[3] = Phase 2 Low
														Phases[4] = Phase 2 High
														Phases[5] = Phase 2 Low
											unit8_t* hallPosition - contains the computed hall position
	
	Return value: None
*/
void getPhasesReverse(bool* Phases, uint8_t hallPosition){
	for(int i = 0; i < 6; i++){ //For all 6 phases
		*(Phases + i) = BRIDGE_STEPS_REVERSE[hallPosition][i]; //Access look up table
	}
}

//-------------------------------------------------------------------------------------------------
// FUNCTIONS FOR CONTROLLING THE PWM
//-------------------------------------------------------------------------------------------------

/*
	Description: stops the timers of all 6 PWM signals
	
	Input parameters: 	None
	
	Return value: None
*/
void stopTimerPWM(){
	HAL_TIM_PWM_Stop(&htim1, TIM_CHANNEL_1); //Phase 1 High
	HAL_TIM_PWM_Stop(&htim1, TIM_CHANNEL_2); //Phase 1 Low
	HAL_TIM_PWM_Stop(&htim1, TIM_CHANNEL_3); //Phase 2 High
	HAL_TIM_PWM_Stop(&htim1, TIM_CHANNEL_4); //Phase 2 Low
	HAL_TIM_PWM_Stop(&htim8, TIM_CHANNEL_1); //Phase 3 High
	HAL_TIM_PWM_Stop(&htim8, TIM_CHANNEL_2); //Phase 3 Low
}

/*
	Description: starts the timers of all 6 PWM signals
	
	Input parameters: 	None
	
	Return value: None
*/
void startTimerPWM(){
	HAL_TIM_PWM_Start(&htim1, TIM_CHANNEL_1); //Phase 1 High
	HAL_TIM_PWM_Start(&htim1, TIM_CHANNEL_2); //Phase 1 Low
	HAL_TIM_PWM_Start(&htim1, TIM_CHANNEL_3); //Phase 2 High
	HAL_TIM_PWM_Start(&htim1, TIM_CHANNEL_4); //Phase 2 Low
	HAL_TIM_PWM_Start(&htim8, TIM_CHANNEL_1); //Phase 3 High
	HAL_TIM_PWM_Start(&htim8, TIM_CHANNEL_2); //Phase 3 Low
}

/*
	Description: sets the duty cicle of all 6 PWM signals to 0
	
	Input parameters: 	None
	
	Return value: None
*/
void setNullDutyCiclePWM(){
	TIM1->CCR1 = 0; //Phase 1 High
	TIM1->CCR2 = 0; //Phase 1 Low
	TIM1->CCR3 = 0; //Phase 2 High
	TIM1->CCR4 = 0; //Phase 2 Low
	TIM8->CCR1 = 0; //Phase 3 High
	TIM8->CCR2 = 0; //Phase 3 Low
}

/*
	Description: sets the duty cicle of all 6 PWM signals according to the computed phases.
	The duty cicle is given by dutyValue (should be sclaed, that is, between 0 and 4200)
	
	Input parameters: 	bool* Phases - array containing the 6 phases
														Phases[0] = Phase 1 High
														Phases[1] = Phase 1 Low
														Phases[2] = Phase 2 High
														Phases[3] = Phase 2 Low
														Phases[4] = Phase 2 High
														Phases[5] = Phase 2 Low
											int dutyValue - int containing the desired duty cicle (between 0 and 4200)
	
	Return value: None
*/
void setDutyCiclePWM(bool Phases[6], int dutyValue){
	TIM1->CCR1 = Phases[0] * dutyValue; //Phase 1 High
	TIM1->CCR2 = Phases[1] * dutyValue; //Phase 1 Low
	TIM1->CCR3 = Phases[2] * dutyValue; //Phase 2 High
	TIM1->CCR4 = Phases[3] * dutyValue; //Phase 2 Low
	TIM8->CCR1 = Phases[4] * dutyValue; //Phase 3 High
	TIM8->CCR2 = Phases[5] * dutyValue; //Phase 3 Low
}

/*
	Description: sets the duty cicle of the 3 PWM signals going to the high phases to 0, and the 3 PWM
	signals going to the low phases to dutyValue (should be sclaed, that is, between 0 and 4200)
	
	Input parameters: 	bool* Phases - array containing the 6 phases
														Phases[0] = Phase 1 High
														Phases[1] = Phase 1 Low
														Phases[2] = Phase 2 High
														Phases[3] = Phase 2 Low
														Phases[4] = Phase 2 High
														Phases[5] = Phase 2 Low
											int dutyValue - int containing the desired duty cicle (between 0 and 4200)
	
	Return value: None
*/
void setBrakingDutyCiclePWM(int dutyValue){
	TIM1->CCR1 = 0; //Phase 1 High
	TIM1->CCR3 = 0; //Phase 2 High
	TIM8->CCR1 = 0; //Phase 3 High
	TIM1->CCR2 = dutyValue; //Phase 1 Low
	TIM1->CCR4 = dutyValue; //Phase 2 Low
	TIM8->CCR2 = dutyValue; //Phase 3 Low
}

/*
	Description: given the desired duty cycle and the past duty cycle, ensures that the difference
	between the two does not exceed maxDelta (to avoid very abrupt acceleration or excessive current
	spikes), but only if desDuty > pastDuty
	
	Input parameters:  desDuty - inputs desired duty cycle to be inputted to the motor
														 - returns the duty cycle that should be inputted to the motor
									   pastDuty - inputs past duty cycle supplied to the motor
															- returns the duty cycle that should be inputted to the motor
										 maxDelta - the maximum difference between desDuty and pastDuty (assuming desDuty
																is > than pastDuty)

	Return value: None

*/
void regulateDeltaPWM(int* desDuty, int* pastDuty, int maxDelta){
	if(((*desDuty) - (*pastDuty)) > maxDelta){
		(*desDuty) = (*pastDuty) + maxDelta;
	}
	(*pastDuty) = (*desDuty);
}

//-------------------------------------------------------------------------------------------------
// FUNCTIONS FOR DEBUGGING
//-------------------------------------------------------------------------------------------------

/*
	Description: uses the on-board LEDs to give information about the state of the system (for
	debugging purposes)
	
	Input parameters: 	None
	
	Return value:		None
*/
void LED_stateMachine (uint8_t systemState, bool Halls[3], uint32_t globalHeartbeat_50us, 
	uint32_t hallLED_state) {
    switch (systemState) {
			case 0: //Working normally
				if ((globalHeartbeat_50us - hallLED_state) > 20000) {
					HAL_GPIO_TogglePin(GPIOD, LD4_Pin);
					hallLED_state = globalHeartbeat_50us;
				}

				if (Halls[0])
					HAL_GPIO_WritePin(GPIOD, LD3_Pin, GPIO_PIN_SET);
				else
					HAL_GPIO_WritePin(GPIOD, LD3_Pin, GPIO_PIN_RESET);

				if (Halls[1])
					HAL_GPIO_WritePin(GPIOD, LD5_Pin, GPIO_PIN_SET);
				else
					HAL_GPIO_WritePin(GPIOD, LD5_Pin, GPIO_PIN_RESET);

				if (Halls[2])
					HAL_GPIO_WritePin(GPIOD, LD6_Pin, GPIO_PIN_SET);
				else
					HAL_GPIO_WritePin(GPIOD, LD6_Pin, GPIO_PIN_RESET);

				break;

			case 1: //Hall effect problem
				if ((globalHeartbeat_50us - hallLED_state) > 10000) {
					HAL_GPIO_WritePin(GPIOD, LD4_Pin,GPIO_PIN_RESET);

					//toggle hall effect LEDs
					HAL_GPIO_TogglePin(GPIOD, LD3_Pin);
					HAL_GPIO_TogglePin(GPIOD, LD5_Pin);
					HAL_GPIO_TogglePin(GPIOD, LD6_Pin);

					hallLED_state = globalHeartbeat_50us;
				}
				break;

			case 99: //Dead Man
				if ((globalHeartbeat_50us - hallLED_state) > 5000) {
					HAL_GPIO_WritePin(GPIOD, LD4_Pin,GPIO_PIN_RESET);
					HAL_GPIO_WritePin(GPIOD, LD3_Pin,GPIO_PIN_RESET);
					HAL_GPIO_WritePin(GPIOD, LD6_Pin,GPIO_PIN_RESET);

					//toggle red LED
					HAL_GPIO_TogglePin(GPIOD, LD5_Pin);

					hallLED_state = globalHeartbeat_50us;
				}
				break;
		}
}

//-------------------------------------------------------------------------------------------------
// PID FUNCTIONS
//-------------------------------------------------------------------------------------------------

/*
	Description: uses the time between two hall transitions to compute the motor speed in RPM
	
	Input parameters:		int measuredSpeed - the computed speed will be stored here
											uint32_t globalHeartbeat_50us - contains the global 50us heartbeat
											uint8_t hallPosition - contains the computed hall position
											uint32_t hallEffectTick - contains the hearbeat of last hallEffect registered
													change. Will be updated to the current heartbeat.
											uint8_t lastHallPosition - will be update to the current hall position
	
	Return value:		None
*/
void computeHallSpeed(int* measuredSpeed, uint32_t globalHeartbeat_50us, uint8_t hallPosition, 
			uint32_t* hallEffectTick, uint8_t* lastHallPosition){
	//Time between two transitions (ttr) in seconds:
	//	ttr (us) = (globalHeartbeat_50us - hallEffectTick) * 50 (in us)
	//	ttr  (s) = ((globalHeartbeat_50us - hallEffectTick) * 50) / 1000000 (in s)
	//Electrical frequency (ef) = (1.0/6) / ttr (in Hz)
	//  ef = 1.0 / (6*ttr)
	//	ef = 1000000 / (6 * (globalHeartbeat_50us - hallEffectTick) * 50)
	//RPM = 60 * ef * n_pol_pairs
	//  rpm = 180000000 / (6 * (globalHeartbeat_50us - hallEffectTick) * 50)
	//	rpm = 3600000 / (6 * (globalHeartbeat_50us - hallEffectTick))
	//  rpm = 600000 / (globalHeartbeat_50us - hallEffectTick)
	//(*measuredSpeed) = (int) (600000.0 / (globalHeartbeat_50us - (*hallEffectTick)));
	(*measuredSpeed) = ((float) (getEncoderChanges(*lastHallPosition, hallPosition) * 200000)) / (globalHeartbeat_50us - (*hallEffectTick));
	(*hallEffectTick) = globalHeartbeat_50us;
	(*lastHallPosition) = hallPosition;
}


/*
	Description: computes the demanded speed (proportional to the scaled acceleration pedal value)
	When the scaled pedal value = 1 (full press), then the demanded speed is the maximum motor speed
	When the scaled pedal value = 0 (no press), then the demanded speed is 0
	
	Input parameters:		int demandedSpeed - the computed demanded speed will be stored here
											int accelPedalValue_scaled - the scaled acceleration pedal value
											int maxMotorSpeed - the maximum motor speed
	
	Return value:		None
*/
void getDemandedSpeed(int* demandedSpeed, int accelPedalValue_scaled, int maxMotorSpeed){
	(*demandedSpeed) = ((float) accelPedalValue_scaled / 4200) * maxMotorSpeed;
}

/*
	Description: saturates an input value according to the input maximum and minimum
	If the value is higher than the maximum, the value will be changed to the maximum
	If the values is lower than the minimum, the value wll be changed to the minimum

	Input parameters:		int val - the value to be saturated (and stored here)
											int max_val - the maximum value
											int min_val - the minimum value
	
	Return value:		None
*/
void scaleSaturationInt(int* val, int min_val, int max_val){
	if((*val) > max_val){
		(*val) = max_val;
	} else if ((*val) < min_val){
		(*val) = min_val;
	}
}

/*
	Description: applies PI velocity control with anti-windup.

	Input parameters:		int controlOutput - the PI control output will be stored here
											int demandedSpeed - the target speed
											int measuredSpeed - the measured speed (measured using hall sensors)
											float actuatorSaturationPoint - contol output value from which the actuator is saturated
											float speedErrorSum - the integral error of the PI. It is updated
											float Kp - gain of the proportional error
											float Ki - gain of the integral error
	
	Return value:		None
*/
void getControlOutput(int* controlOutput, int demandedSpeed, int measuredSpeed, float actuatorSaturationPoint, 
	float* speedErrorSum, float Kp, float Ki, float windupGain){
	
	int speedError = demandedSpeed - measuredSpeed; //error
		
	int KpTerm = speedError * Kp;
	
	//Clamp the Kp output
	int maxKpTerm = 1400;
	if(KpTerm > maxKpTerm){ KpTerm = maxKpTerm;}
	
  (*controlOutput) = KpTerm + (*speedErrorSum);
	
	
	float windup = 0; 
	if((*controlOutput) > actuatorSaturationPoint){ //If positively saturated
		windup = actuatorSaturationPoint - (*controlOutput);
	} else if ((*controlOutput) < (actuatorSaturationPoint * -1)){ //If negatively saturated
		windup = (actuatorSaturationPoint * -1) - (*controlOutput);
	}
	
	(*speedErrorSum) = (*speedErrorSum) + Ki*speedError + windupGain*windup;
}

/*
	Description: computes the PWM duty cicle for the motor controller according to the PID output
	Voltage that should be supplied to the motor (V) = motorSpeedConstant (V/RPM) * controlOutput
	PWM duty cicle = maximum duty cicle * voltage that should be supplied / supply voltage
	The PWM duty cicle must be between -4200 and 4200. A negative duty cicle indicates that the PWM
	phases used will be the braking phases. 

	Input parameters:		int demandedPWMdutyCicle - the PWM duty cicle will be stored here
											int controlOutput - the output from the PID
											float motorSpeedConstant - motor speed constant in V/RPM
											uint8_t supplyVoltage - voltage supplied to the motor when at full duty cicle
	
	Return value:		None
*/
void getDemandedPWM(int* demandedPWMdutyCicle, int controlOutput, float motorSpeedConstant,  
	float motorBrakeConstant, uint8_t supplyVoltage){
	
	if(controlOutput < 0){ //Deceleration
		(*demandedPWMdutyCicle) = 4200 * ((motorBrakeConstant * controlOutput) / supplyVoltage);
	} else { //Acceleration
		(*demandedPWMdutyCicle) = 4200 * ((motorSpeedConstant * controlOutput) / supplyVoltage);
	}
  scaleSaturationInt(demandedPWMdutyCicle, -4200, 4200); //Saturate between -maxDutyCicle and maxDutyCicle
	
	//If this is not work then it may be necesary to use a different motorSpeedConstant when braking and accelerationg
}

/*
	Description: computes PI contol output value from which the actuator is saturated. The atuator is
	saturated if the demanded PWM duty cicle exceeds the maximum duty cicle.

	Input parameters:		float actuatorSaturationPoint - the actuator saturation point will be sotred here
											int supplyVoltage - voltage supplied to the motor when at full duty cicle
											float motorSpeedConstant - motor speed constant in V/RPM
	
	Return value:		None
*/
void getActuatorSaturationPoint(float* actuatorSaturationPoint, int supplyVoltage, float motorSpeedConstant){
	// demandedPWMDutyCicle = MaxDutyCicle * motorConstant * ControlOutput / supplyVoltage
	// At the saturation point demandedPWMDutyCicle = MaxDutyCicle, therefore the eq above turns into
	// 1 = motorConstant * ControlOutput * supplyVoltage.
	// Rearanging, the control output to achieve saturation is
	// ControlOutput = supplyVoltage / motorConstant
	(*actuatorSaturationPoint) = supplyVoltage / motorSpeedConstant;
}

int getEncoderChanges(uint8_t lastHallPosition, uint8_t hallPosition){
	return ENCODER_CHANGES[lastHallPosition][hallPosition];
}	

//-------------------------------------------------------------------------------------------------
// AUTOMATIC CONTROL FUNCTIONS
//-------------------------------------------------------------------------------------------------

/*
	Description: Implements a one-dimensional lookup table to find output y for input x. Returns 1 if
	the input x fall within the range of the lookup table, 0 otherwise.
	
	Input parameters: int* Y - pointer used to return output Y
										int X  - input x
										float dX - distance between the x data values of the lookup table
										int nX - size of the table array
										int tableArr[] - array containing the lookup table
			
*/
int sampleLookupTable(int* Y, int X, float dX, int nX, int tableArr[]){
	if(X < 0){ //Lookup table only has positive values on the X axis
		(*Y) = 0; // Safety feature (stop motor)
		return 0;
	}
	int tableIndx = X / dX;
	if((tableIndx >= 0) && (tableIndx <= (nX-1))){ //Within table bounds
		(*Y) = tableArr[tableIndx]; //Read array
		return 1;
	} else {
		(*Y) = 0; // Safety feature (stop motor)
		return 0;
	}				
}
