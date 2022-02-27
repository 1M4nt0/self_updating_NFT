//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "base64-sol/base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract self_updating_NFT is ERC721URIStorage {

	uint256 public tokenCounter;
	event CreatedSVGNFT(uint256 indexed tokenId, string tokenURI);

	uint256 private _xPos;
	uint256 private _yPos;
	string private _baseSVGMarkdown;
	string private _contentSVGMarkdown;

	constructor() ERC721("TEST", "TESTNFT") {
		tokenCounter = 0;
		_xPos = 0;
		_yPos = 0;
    }

	function contentSVGMarkdown() public view returns (string memory){
		return _contentSVGMarkdown;
	}

	function _afterTokenTransfer(address, address, uint256) internal override {
		if(!(_xPos == 1000 && _yPos == 1000) && !(_xPos == 0 && _yPos == 0)){
			string memory updatedContent = string(abi.encodePacked(_contentSVGMarkdown, getNextBlackSquare()));
			string memory fullRawURI = getFullSVGImage(updatedContent);
			_contentSVGMarkdown = updatedContent;
			string memory imageURI = svgToImageURI(fullRawURI);
			string memory tokenURI = formatTokenURI(imageURI);
			_setTokenURI(tokenCounter, tokenURI);
			if(_xPos == 1000){
				_xPos = 0;
				_yPos = _yPos + 100;
			}else{
				_xPos = _xPos + 100;
			}
		}
	}

	function getNextBlackSquare() internal view returns (string memory) {
		return string(abi.encodePacked(
			'<rect x="',
			Strings.toString(_xPos),
			'" y="',
			Strings.toString(_yPos),
			'" width="100" height="100" stroke="black" />'
		));
	}

	function getFullSVGImage(string memory content) internal pure returns (string memory) {
		string memory baseSVGMarkdown = '<svg xmlns="http://www.w3.org/2000/svg" width="1000" height="1000">';
		return string(abi.encodePacked(baseSVGMarkdown, content, '</svg>'));
	}

	function create() public {
		_safeMint(msg.sender, tokenCounter);
		string memory blackSquare = getNextBlackSquare();
		string memory fullRawURI = getFullSVGImage(blackSquare);
		_contentSVGMarkdown = blackSquare;
		string memory imageURI = svgToImageURI(fullRawURI);
		string memory tokenURI = formatTokenURI(imageURI);
		_setTokenURI(tokenCounter, tokenURI);
		emit CreatedSVGNFT(tokenCounter, tokenURI);
		_xPos = 100;
	}

	function svgToImageURI(string memory _svg) public pure returns (string memory){
		string memory baseURL = "data:image/svg+xml;base64,";
		string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(_svg))));
		string memory imageURI = string(abi.encodePacked(baseURL,svgBase64Encoded));
		return imageURI;
	}

	function formatTokenURI(string memory _imageURI) public pure returns (string memory) {
		string memory baseURL = "data:application/json;base64,";
		return string(abi.encodePacked(
			baseURL,
			Base64.encode(
				bytes(abi.encodePacked(
					'{"name:" "TEST", ', 
					'"description": "TEST NFT", ', 
					'"attributes": "", ', 
					'"image": "', _imageURI, '"}'
				))
		)));
	}
}