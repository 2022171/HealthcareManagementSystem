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
