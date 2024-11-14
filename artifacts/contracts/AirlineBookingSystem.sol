// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; // This specifies the version of Solidity being used, in this case, version 0.8.0 or later.

// Define the Airline contract
contract Airline {
    // State variable that stores the owner's address (Airline's address)
    address public owner; // The address of the contract deployer (airline owner). Public so it can be accessed from outside the contract.
    
    uint public ownerBalance; // The balance accumulated by the airline, i.e., the total Ether received from customers for bookings.

    // Define the structure of a flight
    struct Flight {
        string destination;  // Destination of the flight (e.g., "Paris").
        uint price;          // Price of the flight in wei (smallest unit of Ether).
        uint totalSeats;     // Total seats available for the flight.
        uint bookedSeats;    // Number of seats already booked.
    }

    // Mapping to store flights, accessible by a flight ID (integer).
    mapping(uint => Flight) public flights;  // Mapping of flight ID to Flight structure. Public so it can be accessed directly.
    
    uint public flightCount;  // Counter for flights, used to assign unique IDs to each flight added.

    // Event declarations for tracking actions (important for logging events on the blockchain)
    event FlightAdded(uint flightId, string destination, uint price, uint totalSeats);  // Emitted when a new flight is added.
    event FlightBooked(address customer, uint flightId, uint numberOfSeats, uint totalCost);  // Emitted when a customer books a flight.
    event PaymentReceived(address customer, uint amount);  // Emitted when payment is received for a booking.
    event FlightCancelled(address customer, uint flightId, uint refundedAmount);  // Emitted when a customer cancels a booking and is refunded.

    // Modifier to restrict certain functions to the owner only (airline operator)
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action.");  // Ensures only the owner (airline) can execute certain functions.
        _;  // Continuation of the function execution.
    }

    // Constructor function to set the contract deployer as the owner
    constructor() {
        owner = msg.sender; // Set the contract deployer as the owner (airline).
    }

    // Function to add a new flight to the system (Airline can add new flights)
    function addFlight(string memory _destination, uint _price, uint _totalSeats) public onlyOwner {
        flights[flightCount] = Flight(_destination, _price, _totalSeats, 0);  // Add the new flight to the mapping with a unique flight ID (flightCount).
        emit FlightAdded(flightCount, _destination, _price, _totalSeats);  // Emit the FlightAdded event to log the new flight.
        flightCount++;  // Increment the flight counter to assign a unique flight ID for the next flight.
    }

    // Function to book a flight
    function bookFlight(uint _flightId, uint _numberOfSeats) public payable {
        require(_flightId < flightCount, "Invalid flight ID.");  // Ensure that the flight ID is valid.
        Flight storage flight = flights[_flightId];  // Get the flight from the mapping using the flight ID.

        uint totalCost = flight.price * _numberOfSeats;  // Calculate the total cost for booking the requested number of seats.
        require(flight.bookedSeats + _numberOfSeats <= flight.totalSeats, "Not enough available seats.");  // Ensure there are enough seats available.
        require(msg.value == totalCost, "Incorrect payment amount.");  // Ensure the sent Ether equals the total cost.

        // Update the booked seats and accumulate the payment
        flight.bookedSeats += _numberOfSeats;  // Increase the number of booked seats for the flight.
        ownerBalance += msg.value;  // Add the received payment (msg.value) to the airline's balance.

        emit FlightBooked(msg.sender, _flightId, _numberOfSeats, totalCost);  // Emit the FlightBooked event to log the booking.
        emit PaymentReceived(msg.sender, msg.value);  // Emit the PaymentReceived event to log the payment.
    }

 // Function to cancel a booking
function cancelBooking(uint _flightId, uint _numberOfSeats) public payable {
    require(_flightId < flightCount, "Invalid flight ID.");
    Flight storage flight = flights[_flightId];
    require(flight.bookedSeats >= _numberOfSeats, "Not enough seats booked.");

    uint refundAmount = flight.price * _numberOfSeats;  // Calculate the refund amount.

    // Ensure the contract has enough funds to refund
    require(ownerBalance >= refundAmount, "Not enough balance in contract to refund.");

    // Refund the customer
    payable(msg.sender).transfer(refundAmount);  // Refund to the customer.

    // Update the booked seats and owner balance
    flight.bookedSeats -= _numberOfSeats;  // Decrease the number of booked seats.
    ownerBalance -= refundAmount;  // Decrease the airline balance by the refunded amount.

    emit FlightCancelled(msg.sender, _flightId, refundAmount);  // Log the cancellation.
}

    // Function to withdraw funds accumulated in the contract (Only owner can withdraw)
    function withdrawBalance() public onlyOwner {
        uint amount = ownerBalance;  // Get the accumulated balance of the contract.
        ownerBalance = 0;  // Reset the owner's balance to zero after withdrawal.
        payable(owner).transfer(amount);  // Transfer the accumulated balance to the owner's address (airline).
    }

    // Function to get the details of a specific flight (can be called by anyone)
    function getFlightDetails(uint _flightId) public view returns (string memory destination, uint price, uint bookedSeatsAvailable) {
        require(_flightId < flightCount, "Invalid flight ID.");  // Ensure the flight ID is valid.
        Flight memory flight = flights[_flightId];  // Get the flight details from the mapping.
        uint availableSeats = flight.totalSeats - flight.bookedSeats;  // Calculate the available seats by subtracting booked seats from total seats.
        return (flight.destination, flight.price, availableSeats);  // Return the flight destination, price, and available seats.
    }
}
