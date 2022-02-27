// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "base64-sol/base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract self_updating_NFT_enhanced is ERC721URIStorage, Ownable {

	struct Color {
		uint red;
		uint green;
		uint blue;
	}

	Color[] private colors;
	uint256 private numberOfMeshes = 12;

	constructor() ERC721("TEST", "TESTNFT") {
		colors.push(Color(23, 18, 25)); 		// Blue
		colors.push(Color(34, 85, 96)); 		// Light Blue
		colors.push(Color(237, 240, 96)); 		// Yellow
		colors.push(Color(240, 128, 60)); 		// Orange
		colors.push(Color(49, 13, 32)); 		// Bordeaux
		create();
    }

	function generateNewSvgURI() internal view returns (string memory) {
		uint256 ownerUint = uint256(uint160(address(ownerOf(0))));
		bytes memory updatedContent = abi.encodePacked(getNextMesh(ownerUint));
		for(uint i = 1; i < numberOfMeshes; i++){
			uint256 randomNumber = uint256(keccak256(abi.encode(ownerUint, i)));
			updatedContent = abi.encodePacked(updatedContent, getNextMesh(randomNumber));
		}
		string memory fullRawURI = getFullSVGImage(string(updatedContent));
		string memory imageURI = svgToImageURI(fullRawURI);
		return formatTokenURI(imageURI);	
	}

	function _afterTokenTransfer(address, address, uint256) internal override {
		_setTokenURI(0, generateNewSvgURI());
	}

	function getNextMesh(uint256 _randomNumber) internal view returns (string memory) {
		uint256 m_xPos = (uint256(keccak256(abi.encode(_randomNumber, 1252312335))) % 800);
		uint256 m_yPos = (uint256(keccak256(abi.encode(_randomNumber, 25123132))) % 800);
		uint256 m_height = (uint256(keccak256(abi.encode(_randomNumber, 336235235))) % 500) + 50;
		uint256 m_width = (uint256(keccak256(abi.encode(_randomNumber, 52351234))) % 500) + 50;
		Color memory m_color = colors[uint256(keccak256(abi.encode(_randomNumber, 23542345))) % 5];

		return string(abi.encodePacked(
			'<rect x="',
			Strings.toString(m_xPos),
			'" y="',
			Strings.toString(m_yPos),
			'" width="',
			Strings.toString(m_width),
			'" height="',
			Strings.toString(m_height),
			'" fill="rgba(',
			Strings.toString(m_color.red),
			',',
			Strings.toString(m_color.green),
			',',
			Strings.toString(m_color.blue),
			',0.4)" />'
		));
	}

	function getFullSVGImage(string memory content) internal pure returns (string memory) {
		string memory baseSVGMarkdown = '<svg xmlns="http://www.w3.org/2000/svg" fill="white" width="1000" height="1000">';
		return string(abi.encodePacked(baseSVGMarkdown, content, '</svg>'));
	}

	function create() internal {
		_safeMint(msg.sender, 0);
		string memory imageURI = generateNewSvgURI();
		_setTokenURI(0, imageURI);
	}

	function svgToImageURI(string memory _svg) internal pure returns (string memory){
		string memory baseURL = "data:image/svg+xml;base64,";
		string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(_svg))));
		return string(abi.encodePacked(baseURL,svgBase64Encoded));
	}

	function formatTokenURI(string memory _imageURI) internal pure returns (string memory) {
		string memory baseURL = "data:application/json;base64,";
		return string(abi.encodePacked(
			baseURL,
			Base64.encode(
				bytes(abi.encodePacked(
					'{"name":"TEST", ', 
					'"description": "TEST NFT", ', 
					'"attributes": "", ', 
					'"image": "', _imageURI, '"}'
				))
		)));
	}
}