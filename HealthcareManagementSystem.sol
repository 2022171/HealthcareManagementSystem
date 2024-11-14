// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HealthcareManagementSystem {
    address public healthcareProvider; // Store the healthcare provider's address

    uint256 public totalPaymentCharged; // Track total payment charged by the provider

// Struct to define treatment types with name and price
    struct TreatmentTypes {
        string treatmentType;
        uint256 treatmentprice;
    }

    // Struct to store patient information
    struct PatientData {
        string name;
        string surname;
        string dateOfBirth;
        uint256 documentNumber;
        string gender;
        string bloodType;
    }
 // Mapping to store treatments by ID and counter for treatment types
    mapping(uint256 => TreatmentTypes) public treatment;
    uint256 public treatmentTypeCount;

    // Mapping to store patient data by patient ID and counter for patients
    mapping(uint256 => PatientData) public patients;
    uint256 public patientCount;
// Events to log important actions (adding patient, choosing treatment, receiving payment)
    event PatientAdded(uint256 patientID, string name, string treatmentType);
    event treatmentChosen(address patient, uint256 patientID, uint256 treatmentCost);
    event PaymentReceived(address patient, uint256 amount);
    
    // Modifier to ensure only the healthcare provider can call certain functions
    modifier onlyHealthcareProvider() {
        require(
            msg.sender == healthcareProvider,
            "Only the Healthcare Provider can perform this action."
        );
        _; // Continue executing the function
    }

    // Constructor to set the deployer as the healthcare provider
    constructor() {
        healthcareProvider = msg.sender;
    }
    // Function to add a new patient, only callable by healthcare provider
    function addNewPatient(
        string memory _name,
        string memory _surname,
        string memory _dateOfBirth,
        uint256 _documentNumber,
        string memory _gender,
        string memory _bloodType
    ) public onlyHealthcareProvider {
        // Store new patient data in the patients mapping
        patients[patientCount] = PatientData(
            _name,
            _surname,
            _dateOfBirth,
            _documentNumber,
            _gender,
            _bloodType
        );

        patientCount++; // Increment patient count for unique ID
    }
    // New function to update patient data but it will update as transaction///
    function updatePatientData(
        uint256 _patientID,
        string memory _name,
        string memory _surname,
        string memory _dateOfBirth,
        uint256 _documentNumber,
        string memory _gender,
        string memory _bloodType
    ) public onlyHealthcareProvider {
        require(_patientID < patientCount, "Patient does not exist.");

        // Update patient data in the mapping
        patients[_patientID] = PatientData(
            _name,
            _surname,
            _dateOfBirth,
            _documentNumber,
            _gender,
            _bloodType
        );
    }
 // Function to add a new treatment type, only callable by healthcare provider
    function addNewTreatment(
        string memory _treatmentType,
        uint256 _treatmentPrice
    ) public onlyHealthcareProvider {
        // Store new treatment data in the treatment mapping
        treatment[treatmentTypeCount] = TreatmentTypes(
            _treatmentType,
            _treatmentPrice
        );
        treatmentTypeCount++; // Increment treatment count for unique ID
    }

// Function for patients to get treatment by paying the required amount
    function getTreatment(uint256 _treatmentID) public payable {
        // Ensure the treatment ID is valid
        require(_treatmentID < treatmentTypeCount, "Invalid treatment ID.");

        // Retrieve treatment details and cost
        TreatmentTypes memory selectedTreatment = treatment[_treatmentID];
        uint256 treatmentCost = selectedTreatment.treatmentprice;

        // Check if the payment matches the treatment cost
        require(msg.value == treatmentCost, "Incorrect payment amount.");

        // Add the payment to the total amount charged
        totalPaymentCharged += msg.value;

        // Emit events for treatment selection and payment received
        emit treatmentChosen(msg.sender, _treatmentID, treatmentCost);
        emit PaymentReceived(msg.sender, msg.value);
    }
