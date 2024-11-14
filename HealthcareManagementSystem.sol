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