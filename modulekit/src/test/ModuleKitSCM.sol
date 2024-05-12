// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { AccountInstance, UserOpData } from "./RhinestoneModuleKit.sol";
import { IERC7579Account, Execution, MODULE_TYPE_VALIDATOR } from "../external/ERC7579.sol";
import { ERC7579Helpers } from "./utils/ERC7579Helpers.sol";
import { ExtensibleFallbackHandler } from "../core/ExtensibleFallbackHandler.sol";
import { ModuleKitUserOp } from "./ModuleKitUserOp.sol";
import { ModuleKitHelpers } from "./ModuleKitHelpers.sol";

library ModuleKitSCM {
    using ModuleKitUserOp for AccountInstance;
    using ModuleKitHelpers for AccountInstance;

    function getExecOps(
        AccountInstance memory instance,
        address target,
        uint256 value,
        bytes memory callData,
        bytes32 sessionKeyDigest,
        bytes memory sessionKeySignature,
        address txValidator
    )
        internal
        returns (UserOpData memory userOpData)
    {
        userOpData = instance.getExecOps(target, value, callData, txValidator);
        bytes1 MODE_USE = 0x00;
        bytes memory signature =
            abi.encodePacked(MODE_USE, abi.encode(sessionKeyDigest, sessionKeySignature));
        userOpData.userOp.signature = signature;
    }

    // wrapper for signAndExec4337
    function getExecOps(
        AccountInstance memory instance,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory callDatas,
        bytes32[] memory sessionKeyDigests,
        bytes[] memory sessionKeySignatures,
        address txValidator
    )
        internal
        returns (UserOpData memory userOpData)
    {
        userOpData = instance.getExecOps(
            ERC7579Helpers.toExecutions(targets, values, callDatas), txValidator
        );
        bytes1 MODE_USE = 0x00;
        bytes memory signature =
            abi.encodePacked(MODE_USE, abi.encode(sessionKeyDigests, sessionKeySignatures));
        userOpData.userOp.signature = signature;
    }
}
