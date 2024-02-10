// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {ERC721A} from "@ERC721A/ERC721A.sol";
import {OwnedERC20} from "./OwnedERC20.sol";

contract LiquidNft is ERC721A{
    error NotOwner();

    OwnedERC20 public immutable TOKEN;
    uint256 public immutable FEE;
    uint256 public constant FEE_PRECISION = 10_000;
    uint256 public constant WRAP_VALUE = 1e18;
    uint256 public immutable UNWRAP_VALUE;

    constructor(string memory name_, string memory symbol_, uint256 tokenSupply_, uint256 fee_)
        ERC721A(name_, symbol_)
    {
        TOKEN = new OwnedERC20(name_, symbol_);
        TOKEN.mint(msg.sender, tokenSupply_);
        FEE = fee_;
        UNWRAP_VALUE = WRAP_VALUE - (WRAP_VALUE * fee_ / FEE_PRECISION);
    }

    function wrap(address receiver) public {
        TOKEN.burn(msg.sender, WRAP_VALUE);

        _mint(receiver, 1);
    }

    function wrapMultiple(address receiver, uint256 amount) public {
        TOKEN.burn(msg.sender, WRAP_VALUE * amount);
        _mint(receiver, amount);
    }

    function unwrap(uint256 id, address receiver) public {
        if (ownerOf(id) != msg.sender) {
            revert NotOwner();
        }
        _burn(id);
        TOKEN.mint(receiver, UNWRAP_VALUE);
    }

    function unwrapMultiple(uint256[] calldata ids, address receiver) public {
        uint256 lenght = ids.length;
        for (uint256 i; i < lenght; i += 1) {
            uint256 id = ids[i];
            if (ownerOf(id) != msg.sender) {
                revert NotOwner();
            }
            _burn(id);
        }
        TOKEN.mint(receiver, UNWRAP_VALUE * lenght);
    }
}
